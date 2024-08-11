---
layout: post
title: "Don't use complex expressions in if conditions"
description: 'I explain how to refactor complex if conditions'
---

# Don't use complex expressions in if conditions

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
boolean addressedToAll = hotelUser && notification.type.toAllHotelUsers || reservationId && notification.type.toAllReservations
boolean shouldSendByHotel = hotelMatches && (addressedToAll || isAdmin)
boolean senderIsNotReceiver = userId != notification.authorId || notification.authorId == null
boolean notificationMatchesUser = senderIsNotReceiver && (reservationMatches || facilityMatches || shouldSendByHotel)

if (notificationMatchesUser) {
    send(notification)
}
```

What did we do? We split the complex expression to sub-expressions by giving them meaningful names.

This way the code is much <ins>easier to maintain and reason about</ins>. 

For a complex `if` condition it's hard to reason if the condition is correct (and exhaustive) in a sense of complying to the business requirements. 

In the first piece of code above we see that it sends a notification under some conditions. But what are those conditions and if they satisfy the business needs is hard to tell. 

In the refactored code we clearly see that the notification is only sent when it matches the user (business requirement). And "matches the user" means sender is not receiver and either the reservation (of user) matches or the facility (of user) matches or sending is favored by the hotel (of user). And so on.

Every time you assign a name to something you have a chance to think if the name describes that "something" correctly. So by just doing this rewrite you can identify the bug.

Additionally, the refactored code is much <ins>easier to debug</ins>. When the `if` condition appears to be incorrect, you just put a breakpoint, and you immediately see the actual values of all sub-expressions. Therefore, you easily see which sub-expression gives incorrect result.

> ##### TIP
>
> The rule of thumb would be that ideally you should not have `||` or `&&` in your `if` conditions.
{: .block-tip }

It may be OK, though, for trivial cases.

Any of the following is equally good:

```groovy
if (notificationMatchesUser(notification, reservationId, facilityId, hotelIds, userId)) {
    send(notification)
}
```

```groovy
if (notification.matches(reservationId, facilityId, hotelIds, userId)) {
    send(notification)
}
```
