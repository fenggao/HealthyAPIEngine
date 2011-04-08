//
//  HealthyAPITypes.h
//  healthy-iosapp
//
//  Created by Feng Gao on 11-3-15.
//  Copyright 2011 hciatsoton. All rights reserved.
//

typedef enum _HealthyAPIRequestType {
    //ACCOUNT
    HealthyAPILoginSend                = 0, // login user
    HealthyAPIUserStatusRequest        = 1, // check whether current user is still active 
    HealthyAPIUserProfileRequest       = 2, // request user profile
    
    //FOODS 
    HealthyAPIFollowingFoodsRequest    = 3, // request followings' recent foods logs 
    HealthyAPIAllFoodsRequest          = 4, // request all recent foods logs
    HealthyAPIUserFoodsRequest         = 5, // request current user's recent foods logs
    HealthyAPIPopularFoodsRequest      = 6, // request popular foods logs
    HealthyAPIFoodRequest              = 7, // request one food log detail
    HealthyAPIFoodSend                = 8, // post a new food log
    
    //REVIEWS
    HealthyAPIFeedbacksRequest         = 9, // request recent reviews on user's foods logs 
    HealthyAPIFollowingReviewsRequest  = 10, // request followings' recent reviews
    HealthyAPIHeuristicSend            = 11, // post new heuristic review on food log
    HealthyAPICommentSend              = 12, // post new comment review on food log
} HealthyAPIRequestType;

typedef enum _HealthyAPIResponseType {
    //ACCOUNT
    HealthyAPILoginSendResponse            = 0, // response for login : success or failure
    HealthyAPIUserStatusResponse       = 1, // response for status: active or inactive
    HealthyAPIUserProfileResponse      = 2, // user profile data
    
    //FOODS 
    HealthyAPIFollowingFoodsResponse   = 3, // followings' recent foods data
    HealthyAPIAllFoodsResponse         = 4, // all recent foods data
    HealthyAPIUserFoodsResponse        = 5, // current user's recent foods data
    HealthyAPIPopularFoodsResponse     = 6, // popular foods data
    HealthyAPIFoodResponse             = 7, // one food log data
    HealthyAPIFoodSendResponse         = 8, // response for send food log: success of failure
    
    //REVIEWS
    HealthyAPIFeedbacksResponse        = 9, // Feedbacks data
    HealthyAPIFollowingReviewsResponse = 10, // followings' recent reviews data
    HealthyAPIHeuristicSendResponse    = 11, // response for send heuristic review: success of failure
    HealthyAPICommenSendtResponse      = 12, // response for send comment review: success of failure
} HealthyAPIResponseType;
