//
//  PAPCache.h
//  Teamstory
//
//

#import <Foundation/Foundation.h>

@interface PAPCache : NSObject

+ (id)sharedCache;

- (void)clear;
- (void)setAttributesForPhoto:(PFObject *)photo likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser;
- (void)setAttributesForComment:(PFObject *)comment commentLikers:(NSArray *)commentLikers likedByCurrentUser:(BOOL)commentLikedByCurrentUser;
- (NSDictionary *)attributesForPhoto:(PFObject *)photo;
- (NSDictionary *)attributesForComment:(PFObject *)photo;
- (NSNumber *)likeCountForPhoto:(PFObject *)photo;
- (NSNumber *)likeCountForComment:(PFObject *)comment;
- (NSNumber *)commentCountForPhoto:(PFObject *)photo;
- (NSArray *)likersForPhoto:(PFObject *)photo;
- (NSArray *)commentersForPhoto:(PFObject *)photo;
- (void)setPhotoIsLikedByCurrentUser:(PFObject *)photo liked:(BOOL)liked;
- (void)setCommentIsLikedByCurrentUser:(PFObject *)comment liked:(BOOL)liked;
- (BOOL)isPhotoLikedByCurrentUser:(PFObject *)photo;
- (BOOL)isCommentLikedByCurrentUser:(PFObject *)comment;
- (void)incrementLikerCountForComment:(PFObject *)comment;
- (void)decrementLikerCountForComment:(PFObject *)comment;
- (void)incrementLikerCountForPhoto:(PFObject *)photo;
- (void)decrementLikerCountForPhoto:(PFObject *)photo;
- (void)incrementCommentCountForPhoto:(PFObject *)photo;
- (void)decrementCommentCountForPhoto:(PFObject *)photo;

- (NSDictionary *)attributesForUser:(PFUser *)user;
- (NSNumber *)photoCountForUser:(PFUser *)user;
- (BOOL)followStatusForUser:(PFUser *)user;
- (void)setPhotoCount:(NSNumber *)count user:(PFUser *)user;
- (void)setFollowStatus:(BOOL)following user:(PFUser *)user;

- (void)setFacebookFriends:(NSArray *)friends;
- (NSArray *)facebookFriends;
@end
