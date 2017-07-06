//
//  ParseApi.m
//  Historiejagten Fyn
//
//  Created by Gert Lavsen on 13/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "ParseApi.h"
#import "DataFileHelper.h"
#import "InfoModel.h"
#import "LanguageModel.h"
#import "RouteModel.h"
#import "RouteContentModel.h"
#import "RoutePointModel.h"
#import "RoutePointContentModel.h"
#import "PointOfInterestConnectionModel.h"
#import "PointOfInterestModel.h"
#import "ImageModel.h"
#import "IconModel.h"
#import "QuizModel.h"
#import "QuestionModel.h"
#import "QuizAnswerModel.h"
#import "QuizContentModel.h"
#import "POIContentModel.h"
#import "AvatarModel.h"
#import "Route.h"
#import "PointOfInterest.h"
#import "Quiz.h"
#import "Question.h"
#import "Answer.h"
#import "Language.h"
#import "PointOfInterestConnection.h"
#import "RoutePoint.h"

@implementation ParseApi

- (id) init
{
	if (self = [super init])
	{
        [ParseApi registerParseModels];
	}
	return self;
}

- (NSDate *)logicalOneYearAgo
{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
	NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setYear:-1];
	NSDate *from = [NSDate date];
    
    return [gregorian dateByAddingComponents:offsetComponents toDate:from options:0];
}
//added general
-(BOOL) generalFormat:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}
- (void) getLanguagesWithCompletionBlock:(void (^) (NSArray *languages,NSError *error)) completionBlock
{
	PFQuery *query = [LanguageModel query];
	[query whereKey:@"active" equalTo:@YES];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		NSMutableArray *languages = [[NSMutableArray alloc] initWithCapacity:[objects count]];
		if (!error)
		{
			for (LanguageModel *model in objects)
			{
				if (model.active)
				{
					Language *language = [[Language alloc] init];
					language.code = model.code;
					language.priority = model.priorityList;
                    language.objectId = model.objectId;
                    language.updatedAt = model.updatedAt;
					[languages addObject:language];
				}
			}
		}
		completionBlock(languages, error);
	}];
}

- (void) updateLanguages:(NSArray *)existingObject withCompletionBlock:(void (^) (NSArray *, NSError *error)) completionBlock
{
	completionBlock(nil, nil);
}
- (void) getInfoForLanguage:(Language *)language withCompletionBlock:(void (^) (Info *info,NSError *error)) completionBlock
{
	PFQuery *query = [InfoModel query];
	[query includeKey:@"language"];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        Info *info = [[Info alloc] init];
		if (!error)
		{
			//NSLog(@"no error from parse");
			NSMutableDictionary *titles = [[NSMutableDictionary alloc] initWithCapacity:[objects count]];
			NSMutableDictionary *texts = [[NSMutableDictionary alloc] initWithCapacity:[objects count]];
			for (InfoModel *model in objects)
			{
				//NSLog(@"setting %@", model.title);
				info.objectId = model.objectId;
				info.updatedAt = model.updatedAt;
                
                PFObject *obj = model.language;
                [obj fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    Language *lang = (Language *)object;
                    NSLog(@"key = %@", lang.code);
                    
                    [titles setValue:model.title forKey:lang.code];
                    [texts setValue:model.text forKey:lang.code];
                }];
			}
			info.titles = titles;
			info.texts = texts;
            NSLog(@"titles = %@", info.titles);
		}
		else
		{
			NSLog(@"Error: %@", error);
		}
		completionBlock(info, error);
	}];
}
- (void) updateRoutes:(NSDictionary *)existingObjects forLanguage:(Language *)language withCompletionBlock:(void (^) (NSArray *, NSArray *,NSError *error)) completionBlock
{
	[PFCloud callFunctionInBackground:@"updateRoutesWithContent" withParameters:@{@"existing":existingObjects } block:^(id object, NSError *error)
     {
		if (!error)
		{
			dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
			dispatch_async(queue, ^{
				
				
			NSMutableArray *result = [[NSMutableArray alloc] init];
			NSDictionary *updatedDict = [(NSDictionary *)object valueForKey:@"updated"];
			for (NSString *key in [updatedDict allKeys])
			{
				NSDictionary *routeData = [updatedDict valueForKey:key];
				if (routeData)
				{
					Route *route = [[Route alloc] init];
					//NSLog(@"route: %@", [routeData valueForKey:@"route"]);

					RouteModel *model = (RouteModel *)[routeData valueForKey:@"route"];
					if (model)
					{
						// Content
						NSDictionary *contents = [routeData valueForKey:@"contents"];
						NSMutableDictionary *nameContents = [[NSMutableDictionary alloc] initWithCapacity:[contents count]];
						NSMutableDictionary *infoContents = [[NSMutableDictionary alloc] initWithCapacity:[contents count]];
						for (NSString *key in contents)
						{
							RouteContentModel *contentModel = (RouteContentModel *) [contents valueForKey:key];
							[nameContents setValue:contentModel.name forKey:contentModel.language.code];
							[infoContents setValue:contentModel.info forKey:contentModel.language.code];
							
						}
						route.names = nameContents;
						route.infos = infoContents;
						
						route.pointOfInterestIds = [routeData valueForKey:@"pointOfInterests"];
                        route.centerCoordinates = CLLocationCoordinate2DMake(model.centerCoordinates.latitude, model.centerCoordinates.longitude);
                        IconModel *iconModel = (IconModel *)[routeData valueForKey:@"icon"];
						
						if (iconModel)
						{
							//NSLog(@"icon: %@", iconModel.iconId);
                            
                            NSDictionary *iconDictionary = [self loadIconBlocking:iconModel];
                            route.iconRetina = [iconDictionary objectForKey:@"retina"];
                            route.iconNonRetina = [iconDictionary objectForKey:@"nonRetina"];
                            NSDictionary *pinDictionary = [self loadPinBlocking:iconModel];
							route.pinRetina = [pinDictionary objectForKey:@"retina"];
                            route.pinNonRetina = [pinDictionary objectForKey:@"nonRetina"];
                            
                            NSDictionary *pinInactiveDictionary = [self loadPinInactiveBlocking:iconModel];
							route.pinInactiveRetina = [pinInactiveDictionary objectForKey:@"retina"];
                            route.pinInactiveNonRetina = [pinInactiveDictionary objectForKey:@"nonRetina"];
							
							NSDictionary *arPinDictionary = [self loadArPinBlocking:iconModel];
							route.arPinRetina = [arPinDictionary objectForKey:@"retina"];
                            route.arPinNonRetina = [arPinDictionary objectForKey:@"nonRetina"];
                            
                            NSDictionary *arPinInactiveDictionary = [self loadArPinInactiveBlocking:iconModel];
							route.arPinInactiveRetina = [arPinInactiveDictionary objectForKey:@"retina"];
                            route.arPinInactiveNonRetina = [arPinInactiveDictionary objectForKey:@"nonRetina"];
							
						}
						else
						{
							route.iconRetina = nil;
                            route.iconNonRetina = nil;
							
                            route.pinRetina = nil;
                            route.pinNonRetina = nil;
                            
							route.pinInactiveRetina = nil;
                            route.pinInactiveNonRetina = nil;
							
							route.arPinRetina = nil;
                            route.arPinNonRetina = nil;
                            
							route.arPinInactiveRetina = nil;
                            route.arPinInactiveNonRetina = nil;
                            
						}
                        route.objectId = model.objectId;
						route.updatedAt = model.updatedAt;
                        if (model.avatar)
						{
							route.avatarId = model.avatar.objectId;
                        }
                        [result addObject:route];
					}
				}
			}
            NSArray *deleted = [(NSDictionary *)object valueForKey:@"deleted"];

				dispatch_async(dispatch_get_main_queue(), ^{
					completionBlock(result, deleted, error);
				});
			});
		}
		else
		{
			completionBlock(nil, nil, error);
		}
	}];
}

//added
- (void) radinShapeLogInBtn:(UIButton *) button
{
    button.layer.borderWidth =0;
    button.layer.cornerRadius = 23.0;
    button.layer.masksToBounds = YES;
}

- (void) updateRouteWithObjectId:(NSString *)objectId withCompletionBlock:(void (^) (Route *route, NSError *error)) completionBlock
{
	[PFCloud callFunctionInBackground:@"getRouteWithContent" withParameters:@{@"objectId":objectId } block:^(id object, NSError *error) {
		if (!error)
		{
			dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
			dispatch_async(queue, ^{
				Route *route = [[Route alloc] init];
				RouteModel *model = (RouteModel *)[object valueForKey:@"route"];
                route.routeCoordinates = nil;
                if (model)
				{
					// Content
					NSDictionary *contents = [object valueForKey:@"contents"];
					NSMutableDictionary *nameContents = [[NSMutableDictionary alloc] init];
					NSMutableDictionary *infoContents = [[NSMutableDictionary alloc] init];
                    NSMutableArray *nameforlistContents = [[NSMutableArray alloc] init];
					for (NSString *key in contents)
					{
						RouteContentModel *contentModel = (RouteContentModel *) [contents valueForKey:key];
                        NSLog(@"contentModel_key = %@ %@ %@",contentModel.language.code, contentModel.name, contentModel.info);

                        if (![contentModel.name isEqualToString:@""]) {
                            [nameContents setValue:model.name forKey:contentModel.language.code];
                        }
                        if (![contentModel.info isEqualToString:@""]) {
                            [infoContents setValue:contentModel.info forKey:contentModel.language.code];
                        }
                        [nameforlistContents addObject:model.name];
//                        [nameforlistContents setValue:model.name forKey:contentModel.language.code];
					}
					route.names = nameContents;
					route.infos = infoContents;
                    route.namesforlist = [NSArray arrayWithArray:nameforlistContents];
                    
                    NSLog(@"route names = %@", route.names);
                    NSLog(@"route namesforlist = %@", route.namesforlist);
					route.pointOfInterestIds = [object valueForKey:@"pointOfInterests"];
                    route.centerCoordinates = CLLocationCoordinate2DMake(model.centerCoordinates.latitude, model.centerCoordinates.longitude);
                    IconModel *iconModel = (IconModel *)[object valueForKey:@"icon"];
					
					if (iconModel)
					{
						//NSLog(@"icon: %@", iconModel.iconId);
						
						NSDictionary *iconDictionary = [self loadIconBlocking:iconModel];
						route.iconRetina = [iconDictionary objectForKey:@"retina"];
						route.iconNonRetina = [iconDictionary objectForKey:@"nonRetina"];
						NSDictionary *pinDictionary = [self loadPinBlocking:iconModel];
						route.pinRetina = [pinDictionary objectForKey:@"retina"];
						route.pinNonRetina = [pinDictionary objectForKey:@"nonRetina"];
								
						NSDictionary *pinInactiveDictionary = [self loadPinInactiveBlocking:iconModel];
						route.pinInactiveRetina = [pinInactiveDictionary objectForKey:@"retina"];
						route.pinInactiveNonRetina = [pinInactiveDictionary objectForKey:@"nonRetina"];
								
						NSDictionary *arPinDictionary = [self loadArPinBlocking:iconModel];
						route.arPinRetina = [arPinDictionary objectForKey:@"retina"];
						route.arPinNonRetina = [arPinDictionary objectForKey:@"nonRetina"];
								
						NSDictionary *arPinInactiveDictionary = [self loadArPinInactiveBlocking:iconModel];
						route.arPinInactiveRetina = [arPinInactiveDictionary objectForKey:@"retina"];
						route.arPinInactiveNonRetina = [arPinInactiveDictionary objectForKey:@"nonRetina"];
						
					}
					else
					{
						route.iconRetina = nil;
						route.iconNonRetina = nil;
						
						route.pinRetina = nil;
						route.pinNonRetina = nil;
								
						route.pinInactiveRetina = nil;
						route.pinInactiveNonRetina = nil;
								
						route.arPinRetina = nil;
						route.arPinNonRetina = nil;
						
						route.arPinInactiveRetina = nil;
						route.arPinInactiveNonRetina = nil;
						
					}
                    route.objectId = model.objectId;
					route.updatedAt = model.updatedAt;
					
					if (model.avatar)
					{
						route.avatarId = model.avatar.objectId;
                    }
					dispatch_async(dispatch_get_main_queue(), ^{
						completionBlock(route, error);
					});
                }
			});
		}
		else
		{
			completionBlock(nil, error);
		}
	}];

}

- (void) getUpdatableRouteFromExisting:(NSDictionary *)existingObjects withCompletionBlock:(void (^)(NSArray *updatable, NSArray*deleted, NSError *error)) completionBlock
{
	[PFCloud callFunctionInBackground:@"getUpdatableRoutes" withParameters:@{@"existing":existingObjects } block:^(id object, NSError *error)
	 {
		 //NSLog(@"Get list of updatable Routes");
		 if (!error)
		 {
			 NSArray *updatable = [(NSDictionary *)object valueForKey:@"updatable"];
			 NSArray *deleted = [(NSDictionary *)object valueForKey:@"deleted"];
			 completionBlock(updatable, deleted, error);
		 }
		 else
		 {
			 completionBlock(nil, nil, error);
		 }
	 }];
}
//added
-(void) findNameOfFont
{
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@",family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName:family])
        {
            NSLog(@" %@", name);
        }
    }
    
}
- (void) updatePointOfInterestWithObjectId:(NSString *)objectId withCompletionBlock:(void (^) (PointOfInterest *poi, NSError *error)) completionBlock
{
	//NSLog(@"Gets POIS with id %@", objectId);
	[PFCloud callFunctionInBackground:@"getPointOfInterestWithContent" withParameters:@{@"objectId":objectId } block:^(id object, NSError *error)
	 {
		 dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
		 dispatch_async(queue, ^{
			 if (!error)
			 {
				 PointOfInterest *poi = [[PointOfInterest alloc] init];
                 // NOTE #1: At this point 'poi' is initialized and poi.image is 'nil'
				 PointOfInterestModel *model = (PointOfInterestModel *)[object valueForKey:@"pointOfInterest"];
				 if (model)
				 {
					 // Content
					 //NSLog(@"POI %@", model.name);
					 NSDictionary *contents = [object valueForKey:@"contents"];
					 NSMutableDictionary *titleContents = [[NSMutableDictionary alloc] initWithCapacity:[contents count]];
					 NSMutableDictionary *infoContents = [[NSMutableDictionary alloc] initWithCapacity:[contents count]];
					 NSMutableDictionary *factsContents = [[NSMutableDictionary alloc] initWithCapacity:[contents count]];
					 NSMutableDictionary *imageTitleContents = [[NSMutableDictionary alloc] initWithCapacity:[contents count]];
                     NSMutableDictionary *factsImageTitleContents = [[NSMutableDictionary alloc] initWithCapacity:[contents count]];
					 NSMutableDictionary *videoTitleContents = [[NSMutableDictionary alloc] initWithCapacity:[contents count]];
					 for (NSString *key in contents)
					 {
						 POIContentModel *contentModel = (POIContentModel *) [contents valueForKey:key];
						 [titleContents setValue:contentModel.name forKey:contentModel.language.code];
						 [infoContents setValue:contentModel.info forKey:contentModel.language.code];
						 [factsContents setValue:contentModel.facts forKey:contentModel.language.code];
						 [imageTitleContents setValue:contentModel.imageTitle forKey:contentModel.language.code];
                         [factsImageTitleContents setValue:contentModel.factsImageTitle forKey:contentModel.language.code];
						 [videoTitleContents setValue:contentModel.videoTitle forKey:contentModel.language.code];
					 }
					 
					 poi.titles = titleContents;
					 poi.infos = infoContents;
					 poi.factss = factsContents;
					 poi.imageTitles = imageTitleContents;
                     poi.factsImageTitles = factsImageTitleContents;
					 poi.videoTitles = videoTitleContents;
					 poi.quizId = model.quiz.objectId;
					 //NSLog(@"Quiz %@ %@", poi.quizId, model.quiz.objectId);

					 poi.objectId = model.objectId;
					 poi.updatedAt = model.updatedAt;
					 
                     // NOTE #2: If image, retrieved from delta update, is nil it will not be sat on 'poi'.
                     // NOTE #3: For some reason poi.image is not nil, even though model.image is nil.
                     // NOTE #4: Keep in mind that this is an async block, and only 'init' was called on 'poi',
                     //          also 'poi' is not passed anywhere but the callback below
					     
                     if (model.image)
                     {
                         //NSLog(@"Image: %@", model.image.name);
                         if (![DataFileHelper hasPreloadedFile:[NSString stringWithFormat:@"%@_large", poi.objectId]])
                         {
                             poi.largeImage = [self loadLargeImageBlocking:model.image];
                         }
                         if (![DataFileHelper hasPreloadedFile:[NSString stringWithFormat:@"%@_image", poi.objectId]])
                         {
                             poi.image = [self loadImageBlocking:model.image];
                         }
                     }
                     
                     if (model.factsImage)
                     {
                         NSLog(@"Facts Image: %@", model.factsImage.name);
                         if (![DataFileHelper hasPreloadedFile:[NSString stringWithFormat:@"%@_facts_large", poi.objectId]])
                         {
                             NSLog(@"sets large fact image");
                             NSData *d = [self loadLargeImageBlocking:model.factsImage];
                             poi.factsLargeImage = d;
                             NSLog(@"Data: %@", d);
                             
                         }
                         if (![DataFileHelper hasPreloadedFile:[NSString stringWithFormat:@"%@_facts_image", poi.objectId]])
                         {
                             NSLog(@"sets fact image");
                             NSData *d = [self loadImageBlocking:model.factsImage];
                             poi.factsImage = d;
                             NSLog(@"data: %@", d);
                             
                         }
                     }
                     
					 ////NSLog(@"Coordinates: %f %f", model.coordinates.latitude, model.coordinates.longitude);
					 poi.coordinates = CLLocationCoordinate2DMake(model.coordinates.latitude, model.coordinates.longitude);
					 
					 poi.videoURL = model.videoURL;
                     if (model.audio)
                     {
                         if (![DataFileHelper hasPreloadedFile:[NSString stringWithFormat:@"%@_audio", poi.objectId]])
                         {
                             poi.audio = [model.audio getData];
                         }
                     }
					 poi.autoplay = model.autoplay;
					 poi.parentPOI = model.parentPOI.objectId;
					 poi.unlockPOI = model.unlockPOI.objectId;

					 poi.mapRange = model.mapRange;
					 poi.arRange = model.arRange < 10 ? 10  : model.arRange;
					 poi.clickRange = model.clickRange;
					 poi.autoRange = model.autoRange < 10 ? 10 : model.autoRange;
                     //poi.autoRange = model.autoRange > 200 ? 200 : model.autoRange;
                     poi.noAvatar = model.noAvatar;
                     poi.parentPoint = model.parentPoint;
                     NSLog(@"%@ - %@", model.name, poi.parentPoint ? @"YES" : @"NO");
					 if (!model.noAvatar && model.avatar)
					 {
						 poi.avatarId = model.avatar.objectId;
                    }
                }
				 completionBlock(poi, error);
			 }
			 else
			 {
				 completionBlock(nil, error);
			 }
		 });
	 }];
}
//added
-(void) showDoneKeyboard
{
    //Show the Done on the keyboard begin
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
}
//when press keyboard done button
- (IBAction)doneClicked:(id)sender
{
    
}

- (void) updateAvatarsFromExisting:(NSDictionary *)existingObjects withCompletionBlock:(void (^)(NSArray *updated, NSError *error)) completionBlock
{

	 PFQuery *query = [AvatarModel query];
	 [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		//NSLog(@"avatar findObjectinbackground");
		NSMutableArray *result = [[NSMutableArray alloc]init];
		if (!error)
		{
			//NSLog(@"Avatars no error from parse");
			
			for (AvatarModel *model in objects)
			{
				//NSLog(@"Avatar %@",model.objectId);
				BOOL include = NO;
				if (![existingObjects objectForKey:model.objectId])
				{
					include = YES;
				}
				else
				{
					NSDate *old = [existingObjects valueForKey:model.objectId];
					if ([old compare:model.updatedAt] ==NSOrderedAscending)
					{
						include = YES;
					}
				}
				if (include)
				{
					Avatar *avatar = [[Avatar alloc] init];
					avatar.objectId = model.objectId;
					avatar.updatedAt = model.updatedAt;
					avatar.name = model.avatar;
                    if (![DataFileHelper hasPreloadedFile:[NSString stringWithFormat:@"%@_avatars", model.objectId]])
                    {
                        avatar.avatar = [self loadAvatarBlocking:model];
                    }
					[result addObject:avatar];
				}
			}
		}
		else
		{
			//NSLog(@"Error: %@", error);
		}
		completionBlock(result, error);
	}];
}
- (void) getUpdatablePointOfInterestFromExisting:(NSDictionary *)existingObjects withCompletionBlock:(void (^)(NSArray *updatable, NSArray*deleted, NSError *error)) completionBlock
{
	[PFCloud callFunctionInBackground:@"getUpdatablePointOfInterests" withParameters:@{@"existing":existingObjects } block:^(id object, NSError *error)
	 {
		 //NSLog(@"Get list of updatable POIs");
		 if (!error)
		 {
			 NSArray *deleted = [(NSDictionary *)object valueForKey:@"deleted"];
             NSArray *updatable = [(NSDictionary *)object valueForKey:@"updatable"];
			 completionBlock(updatable, deleted, error);
		 }
		 else
		 {
			 completionBlock(nil, nil, error);
		 }
	 }];
}
- (void) updatePointOfInterests:(NSDictionary *)existingObjects forLanguage:(Language *)language withCompletionBlock:(void (^) (NSArray *updated, NSArray*deleted, NSError *error)) completionBlock
{
	[PFCloud callFunctionInBackground:@"getUpdatablePointOfInterests" withParameters:@{@"existing":existingObjects } block:^(id object, NSError *error)
	{
		//NSLog(@"Get list of updatable POIs");
		if (!error)
		{
			dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
			dispatch_async(queue, ^{
				
				NSArray *updatable = [(NSDictionary *)object valueForKey:@"updatable"];
				__block NSInteger countDown = [updatable count];
				__block NSMutableArray *result = [[NSMutableArray alloc] init];
				if (countDown == 0)
				{
					NSArray *deleted = [(NSDictionary *)object valueForKey:@"deleted"];
					completionBlock(result, deleted, error);
				}
				////NSLog(@"updatable pois %ld %@", [updatable count], updatable);
				for (NSString *objectId in updatable)
				{
					//NSLog(@"Gets POIS with id %@", objectId);
					[PFCloud callFunctionInBackground:@"getPointOfInterestWithContent" withParameters:@{@"objectId":objectId } block:^(id object, NSError *error)
					 {
						 dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
						 dispatch_async(queue, ^{
							 if (!error)
							 {
								 PointOfInterest *poi = [[PointOfInterest alloc] init];
								 PointOfInterestModel *model = (PointOfInterestModel *)[object valueForKey:@"pointOfInterest"];
								 if (model)
								 {
									 // Content
									 //NSLog(@"POI %@", model.name);
									 NSDictionary *contents = [object valueForKey:@"contents"];
									 NSMutableDictionary *titleContents = [[NSMutableDictionary alloc] initWithCapacity:[contents count]];
									 NSMutableDictionary *infoContents = [[NSMutableDictionary alloc] initWithCapacity:[contents count]];
									 NSMutableDictionary *factsContents = [[NSMutableDictionary alloc] initWithCapacity:[contents count]];
									 NSMutableDictionary *imageTitleContents = [[NSMutableDictionary alloc] initWithCapacity:[contents count]];
                                     NSMutableDictionary *factsImageTitleContents = [[NSMutableDictionary alloc] initWithCapacity:[contents count]];
									 NSMutableDictionary *videoTitleContents = [[NSMutableDictionary alloc] initWithCapacity:[contents count]];
									 for (NSString *key in contents)
									 {
										 POIContentModel *contentModel = (POIContentModel *) [contents valueForKey:key];
										 [titleContents setValue:contentModel.name forKey:contentModel.language.code];
										 [infoContents setValue:contentModel.info forKey:contentModel.language.code];
										 [factsContents setValue:contentModel.facts forKey:contentModel.language.code];
										 [imageTitleContents setValue:contentModel.imageTitle forKey:contentModel.language.code];
                                         [factsImageTitleContents setValue:contentModel.factsImageTitle forKey:contentModel.language.code];
										 [videoTitleContents setValue:contentModel.videoTitle forKey:contentModel.language.code];
									 }
									 
									 poi.titles = titleContents;
									 poi.infos = infoContents;
									 poi.factss = factsContents;
									 poi.imageTitles = imageTitleContents;
                                     poi.factsImageTitles = factsImageTitleContents;
									 poi.videoTitles = videoTitleContents;
									 poi.quizId = model.quiz.objectId;
									 poi.objectId = model.objectId;
									 poi.updatedAt = model.updatedAt;
									 //NSLog(@"Quiz %@ %@", poi.quizId, model.quiz.objectId);
                                     if (model.image)
                                     {
                                         //NSLog(@"Image: %@", model.image.name);
                                         if (![DataFileHelper hasPreloadedFile:[NSString stringWithFormat:@"%@_large", poi.objectId]])
                                         {
                                             poi.largeImage = [self loadLargeImageBlocking:model.image];
                                         }
                                         if (![DataFileHelper hasPreloadedFile:[NSString stringWithFormat:@"%@_image", poi.objectId]])
                                         {
                                             poi.image = [self loadImageBlocking:model.image];
                                         }
                                     }
                                     if (model.factsImage)
                                     {
                                         //NSLog(@"Image: %@", model.factsImage.name);
                                         if (![DataFileHelper hasPreloadedFile:[NSString stringWithFormat:@"%@_facts_large", poi.objectId]])
                                         {
                                             poi.factsLargeImage = [self loadLargeImageBlocking:model.factsImage];
                                         }
                                         if (![DataFileHelper hasPreloadedFile:[NSString stringWithFormat:@"%@_facts_image", poi.objectId]])
                                         {
                                             poi.factsImage = [self loadImageBlocking:model.factsImage];
                                         }
                                     }
									 ////NSLog(@"Coordinates: %f %f", model.coordinates.latitude, model.coordinates.longitude);
									 poi.coordinates = CLLocationCoordinate2DMake(model.coordinates.latitude, model.coordinates.longitude);
									 
									 poi.videoURL = model.videoURL;
                                     if (model.audio)
                                     {
                                         if (![DataFileHelper hasPreloadedFile:[NSString stringWithFormat:@"%@_audio", poi.objectId]])
                                         {
                                             poi.audio = [model.audio getData];
                                         }
                                     }
									 poi.parentPOI = model.parentPOI.objectId;
									 poi.unlockPOI = model.unlockPOI.objectId;
									 
									 poi.mapRange = model.mapRange;
									 poi.arRange = model.arRange < 10 ? 10  : model.arRange;
									 poi.clickRange = model.clickRange;
									 poi.autoRange = model.autoRange < 10 ? 10 : model.autoRange;
									 
                                     poi.parentPoint = model.parentPoint;
									 poi.noAvatar = model.noAvatar;
									 if (!model.noAvatar && model.avatar)
									 {
										 poi.avatarId = model.avatar.objectId;
									 }
									 
									 [result addObject:poi];
								 }
								 
							 }
							 countDown--;
							 if (countDown == 0)
							 {
								 NSArray *deleted = [(NSDictionary *)object valueForKey:@"deleted"];
								 
								 dispatch_async(dispatch_get_main_queue(), ^{
									 completionBlock(result, deleted, error);
								 });
							 }
						 });
					 }];
				}
				
			});
		}
		else
		{
			completionBlock(nil, nil, error);
		}
	}];
}

- (void) updatePointOfInterestConnectionsWithCompletionBlock:(void (^) (NSArray *connections, NSError *error)) completionBlock
{
	//NSLog(@"updatePointOfInterestConnectionsWithCompletionBlock");
	[PFCloud callFunctionInBackground:@"getPointOfInterestConnections" withParameters:@{} block:^(id object, NSError *error) {
		//NSLog(@"result %@", error);
		if (!error)
		{
			//NSLog(@"updatePointOfInterestConnectionsWithCompletionBlock no error");
			NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[object count]];
			for (NSDictionary *dict in object)
			{
				PointOfInterestConnection *connection = [[PointOfInterestConnection alloc] init];
				connection.sourceId  = [dict valueForKey:@"source"];
				connection.destId = [dict valueForKey:@"destination"];
				[result addObject:connection];
			}
			completionBlock(result, nil);
		}
		else
		{
			//NSLog(@"updatePointOfInterestConnectionsWithCompletionBlock error %@", error);
			completionBlock(nil, error);
		}
	}];
}

- (void) getRoutePointsForLanguage:(Language *)language withCompletionBlock:(void (^)(NSArray *, NSError *))completionBlock
{
	[PFCloud callFunctionInBackground:@"getRoutePointSystem" withParameters:@{} block:^(id object, NSError *error) {
		//NSLog(@"getRoutePointSystem");
		if (!error)
		{
			//NSLog(@"getRoutePointSystem - no error");
			NSArray *keys = [object allKeys];
			NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[keys count]];
			for (NSString *key in keys)
			{
				NSDictionary *dict = [object valueForKey:key];
                //NSLog(@"Dict: %@", dict);
				RoutePointModel *model = [dict valueForKey:@"routePoint"];
				
				RoutePoint *rp = [[RoutePoint alloc] init];
				
				NSDictionary *contents = [dict valueForKeyPath:@"contents"];
				NSMutableDictionary *t25s = [[NSMutableDictionary alloc] initWithCapacity:[contents count]];
				NSMutableDictionary *t50s = [[NSMutableDictionary alloc] initWithCapacity:[contents count]];
				NSMutableDictionary *t75s = [[NSMutableDictionary alloc] initWithCapacity:[contents count]];
				NSMutableDictionary *t100s = [[NSMutableDictionary alloc] initWithCapacity:[contents count]];
                //NSLog(@"Contents 25: %@", contents);
                
                
				for (NSString *key in contents)
				{
					RoutePointContentModel *contentModel = (RoutePointContentModel *) [contents valueForKey:key];
					[t25s setValue:contentModel.text25 forKey:contentModel.language.code];
					[t50s setValue:contentModel.text50 forKey:contentModel.language.code];
					[t75s setValue:contentModel.text75 forKey:contentModel.language.code];
					[t100s setValue:contentModel.text100 forKey:contentModel.language.code];
				}

				rp.text25s = t25s;
				rp.text50s = t50s;
				rp.text75s = t75s;
				rp.text100s = t100s;
		
				rp.routeId = [dict valueForKey:@"route"];
				rp.pointOfInterestIds = [dict valueForKey:@"pointOfInterests"];
				rp.objectId = model.objectId;
				rp.updatedAt = model.updatedAt;
				
				[result addObject:rp];
			}
			completionBlock(result, error);
		}
		else
		{
			//NSLog(@"getRoutePointSystem - error %@", error);
			completionBlock(nil, error);
		}
	}];
}


- (void) updateQuizzes:(NSDictionary *)existingObjects withCompletionBlock:(void (^) (NSArray *updated, NSArray*deleted, NSError *error)) completionBlock
{
	[PFCloud callFunctionInBackground:@"updatableQuizzes" withParameters:@{@"existing" : existingObjects} block:^(id object, NSError *error) {
		if (!error)
		{
			
			dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
			dispatch_async(queue, ^{
				
				NSArray *updatable = [(NSDictionary *)object valueForKey:@"updatable"];
				NSArray *deleted = [(NSDictionary *)object valueForKey:@"deleted"];

				__block NSInteger countDown = [updatable count];
				__block NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:countDown];
				if (countDown == 0)
				{
					completionBlock(result, deleted, error);
				}
				////NSLog(@"updatable quizzes %ld %@", [updatable count], updatable);
				for (NSString *objectId in updatable)
				{
					//NSLog(@"Gets quiz with id %@", objectId);
					[PFCloud callFunctionInBackground:@"getQuizWithContent" withParameters:@{@"objectId":objectId } block:^(id object, NSError *error)
					 {
						 dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
						 dispatch_async(queue, ^{
							 if (!error)
							 {
								 Quiz *quiz = [[Quiz alloc] init];
								 QuizModel *model = (QuizModel *)[object valueForKey:@"quiz"];
								 if (model)
								 {
									 // Content
									 //NSLog(@"Converting parse object to Quiz %@", model.name);
									 quiz.objectId = model.objectId;
									 quiz.name = model.name;
									 quiz.updatedAt = model.updatedAt;
									 NSDictionary *contents = [object valueForKey:@"contents"];
									 NSMutableDictionary *headerContents    = [[NSMutableDictionary alloc] initWithCapacity:[contents count]];
									 NSMutableDictionary *questionsContents = [[NSMutableDictionary alloc] init];
									 for (NSString *key in contents)
									 {
										 NSDictionary *contentDict = (NSDictionary *) [contents valueForKey:key];
										 QuizContentModel *contentModel = (QuizContentModel *) [contentDict valueForKey:@"content"];
										 [headerContents setValue:contentModel.header forKey:contentModel.language.code];
										 
										 NSArray *questionModels = (NSArray *) [contentDict valueForKey:@"questions"];
										 NSMutableArray *questions = [[NSMutableArray alloc] initWithCapacity:[questionModels count]];
										 for (NSDictionary *questionAnswers in questionModels)
										 {
											 QuestionModel *questionModel = (QuestionModel *) [questionAnswers valueForKey:@"question"];
											 NSArray *answerModels = (NSArray *) [questionAnswers valueForKey:@"answers"];
											 Question *question = [[Question alloc] init];
											 question.question = questionModel.question;
											 NSMutableArray *answers = [[NSMutableArray alloc] initWithCapacity:[answerModels count]];
											 for (QuizAnswerModel *answerModel in answerModels)
											 {
												 Answer *answer = [[Answer alloc] init];
												 answer.answer = answerModel.answer;
												 answer.correct = answerModel.correct;
												 [answers addObject:answer];
											 }
											 question.answers = answers;
											 [questions addObject:question];
										 }
										 [questionsContents setObject:questions forKey:contentModel.language.code];
									 }
									 quiz.headers = headerContents;
									 quiz.questionss = questionsContents;
									 //NSLog(@"Quiz converted %@", quiz.objectId);
									 [result addObject:quiz];
								 }
								 
							 }
							 else
							 {
								 //NSLog(@"Error getting quiz %@", error);
							 }
							 countDown--;
							 if (countDown == 0)
							 {
								 
								 dispatch_async(dispatch_get_main_queue(), ^{
									 completionBlock(result, deleted, error);
								 });
							 }
						 });
					 }];
				}
				
			});
		}
		else
		{
			completionBlock(nil, nil, error);
		}
	}];
}

#pragma mark - private selectors


- (PFObject *) contentForObject:(NSDictionary *)contents fittingLanguage:(Language *)language
{
	PFObject *best;
	for (NSString *key in contents)
	{
		PFObject *model = [contents valueForKey:key];
		
		LanguageModel * modelLang = [model valueForKey:@"language"];
		if ([modelLang.code isEqualToString:language.code])
		{
			return model;
		}
		else
		{
			LanguageModel * bestLang = [best valueForKey:@"language"];
			if (!best || bestLang.priority > modelLang.priority)
			{
				best = model;
			}
		}
	}
	return best;
}

- (NSArray *) loadAvatarBlocking:(AvatarModel *)avatar
{
	NSMutableArray *avatars = [[NSMutableArray alloc] initWithCapacity:3];
	int i = 0;
	if (avatar.image1)
	{
		avatars[i++] = [avatar.image1 getData];
	}
	if (avatar.image2)
	{
		avatars[i++] = [avatar.image2 getData];
	}
	if (avatar.image3)
	{
		avatars[i] = [avatar.image3 getData];
	}
	return avatars;
}

- (NSData *) loadLargeImageBlocking:(ImageModel *)image
{
    ////NSLog(@"Image: %)
	if (image.image)
	{
		return [image.image getData];
	}
	else
	{
		return nil;
	}
}

- (NSData *) loadImageBlocking:(ImageModel *)image
{
	if (image.cropped)
	{
		return [image.cropped getData];
	}
	else if (image.image)
	{
		return [image.image getData];
	}
	else
	{
		return nil;
	}
}

- (NSDictionary *) loadIconBlocking:(IconModel *)model
{
    NSData *iconRetina = [model.iconRetina getData];
    NSData *iconNonRetina = [model.icon getData];
    
    return @{@"retina" : iconRetina, @"nonRetina" : iconNonRetina};
}

- (NSDictionary *) loadPinBlocking:(IconModel *)model
{
    // MT: there is a crash when model.pin is used here
    // but pinNonRetina is anyway not used later so pinRetina works for both
    NSData *pinRetina = [model.pinRetina getData];
    if (!pinRetina) {
        pinRetina= [[NSData alloc] init];
    }
    
    return @{@"retina" : pinRetina, @"nonRetina" : pinRetina};
}

- (NSDictionary *) loadPinInactiveBlocking:(IconModel *)model
{
    NSData *pinInactiveRetina = [model.pinInactiveRetina getData];
    NSData *pinInactiveNonRetina = [model.pinInactive getData];
    
    return @{@"retina" : pinInactiveRetina, @"nonRetina" : pinInactiveNonRetina};
}

- (NSDictionary *) loadArPinBlocking:(IconModel *)model
{
	NSData *pinRetina = [model.arPinRetina getData];
	NSData *pinNonRetina = [model.arPin getData];
    
    return @{@"retina" : pinRetina, @"nonRetina" : pinNonRetina};
	
}

- (NSDictionary *) loadArPinInactiveBlocking:(IconModel *)model
{
    NSData *pinInactiveRetina = [model.arPinInactiveRetina getData];
    NSData *pinInactiveNonRetina = [model.arPinInactive getData];
    
    return @{@"retina" : pinInactiveRetina, @"nonRetina" : pinInactiveNonRetina};
}

	 
//#define kParseApplicationId @"sVGrfVql8qrbteX85x6mslpLc7pa03S12tj5kcLv"
//#define kParseClientKey @"M9ncDaTFz6dJN82J3UMCfYiX32rG3oBGqTUgh6Yu"
#define kParseApplicationId @"teBX2kjl8AKMsxYT7vmoqbtMWaVwtdJNfAiGNSby"
#define kParseClientKey @"dl1NGkgSfSpTufVJIHrzxGB2fDRTgmA81MzdeBUX"

#pragma mark - static methods
+ (void) registerParseModels
{
	NSLog(@"Registering Parse models");
	[AvatarModel registerSubclass];
	[ImageModel registerSubclass];
	[InfoModel registerSubclass];
	[PointOfInterestModel registerSubclass];
	[POIContentModel registerSubclass];
	[IconModel registerSubclass];
	[QuizModel registerSubclass];
	[QuizContentModel registerSubclass];
	[QuestionModel registerSubclass];
	[QuizAnswerModel registerSubclass];
	[RouteContentModel registerSubclass];
	[RouteModel registerSubclass];
	[LanguageModel registerSubclass];
	[RoutePointContentModel registerSubclass];
	[RoutePointModel registerSubclass];
	[PointOfInterestConnectionModel registerSubclass];
	//NSLog(@"Sets Parse application id and client key");
//	[Parse setApplicationId:kParseApplicationId
//				  clientKey:kParseClientKey];
    
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = kParseApplicationId;
        //configuration.server = @"http://178.62.181.128:1337/parse";
        configuration.server = @"http://historiejagt.portaplay.dk:1338/parse";
    }]];
	
}

@end
