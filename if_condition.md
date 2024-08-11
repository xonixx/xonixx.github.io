---
layout: post
title: 'TODO'
description: 'TODO'
image: TODO
---

# Don't use complex expressions in if condition

_August 2024_
     
Let's consider a piece of code below. It belongs to a notification sub-system of some hypothetical application. The code determines if the notification should be sent to any particular user or not. 

```groovy
if ((((reservationId && notification.reservationId == reservationId)
    || (facilityId && notification.facilityId in facilityId)
    || (hotelIds && hotelIds.contains(notification.hotelId)) && (hotelUser && notification.type.toAllHotelUsers || reservationId && notification.type.toAllReservations))
    || (isAdmin && hotelIds.contains(notification.hotelId))
    && (userId != notification.authorId || notification.authorId == null))) 
{
    send(notification)
}
```
              
The code above is absolutely incomprehensible. Let's make it better: 

```groovy
boolean reservationMatches = reservationId && notification.reservationId == reservationId
boolean facilityMatches = facilityId && notification.facilityId in facilityId
boolean hotelMatches = hotelIds && hotelIds.contains(notification.hotelId)
boolean messageAddressedToAll = hotelUser && notification.type.toAllHotelUsers || reservationId && notification.type.toAllReservations
boolean shouldSendByHotel = hotelMatches && (messageAddressedToAll || isAdmin)
boolean senderIsNotReceiver = userId != notification.authorId || notification.authorId == null
boolean notificationMatchesUser = senderIsNotReceiver && (reservationMatches || facilityMatches || shouldSendByHotel)

if (notificationMatchesUser) {
    send(notification)
}
```

What did we do? We split the complex expression to sub-expressions by giving them meaningful names.

This way the code is much **easier to maintain and reason about**. 

For an `if` with a complex condition it's hard to reason if the condition is correct (and exhaustive) in a sense of complying to the business requirements. 

In the example above (1st piece of code) we see that the code sends a notification under some conditions. But what are those conditions and if they satisfy the business needs is hard to tell. 

In the refactored code we clearly see that notification is sent only when it matches user (business requirement). And "matches user" means sender is not receiver and either reservation (of user) matches or facility (of user) matches or sending is favored by the hotel (of user). And so on.

Every time you assign a name to something you have a chance to think if the name describes that "something" correctly. So by just doing this rewrite you can identify the bug.

For the same reason, the refactored code is much **easier to debug**. When the `if` condition appears to be incorrect, you just put a breakpoint, and you immediately see the actual values of all sub-expressions. Therefore, you easily see which sub-expression gives incorrect result.

