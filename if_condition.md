---
layout: post
title: 'TODO'
description: 'TODO'
image: TODO
---

# Don't use complex expressions in if condition

_August 2024_
     
Let's consider a piece of code below. It belongs to a chat sub-system of some hypothetical application. The code determines if the message should be sent to any particular user or not. 

```groovy
if ((((reservationId && message.reservationId == reservationId)
    || (facilityId && message.facilityId in facilityId)
    || (hotelIds && hotelIds.contains(message.hotelId)) && (hotelUser && message.type.toAllHotelUsers || reservationId && message.type.toAllReservations))
    || (isAdmin && hotelIds.contains(message.hotelId))
    && (userId != message.authorId || message.authorId == null))) 
{
    send(message)
}
```
              
The code above is absolutely incomprehensible. Let's make it better: 

```groovy
boolean reservationMatched = reservationId && message.reservationId == reservationId
boolean facilityMatched = facilityId && message.facilityId in facilityId
boolean hotelMatched = hotelIds && hotelIds.contains(message.hotelId)
boolean messageAddressedToAll = hotelUser && message.type.toAllHotelUsers || reservationId && message.type.toAllReservations
boolean shouldSendByHotel = hotelMatched && (messageAddressedToAll || isAdmin)
boolean senderIsNotReceiver = userId != message.authorId || message.authorId == null
boolean shouldSend = senderIsNotReceiver && (reservationMatched || facilityMatched || shouldSendByHotel)

if (shouldSend) {
    send(message)
}
```

What did we do? We split the complex expression to sub-expressions by giving them meaningful names.

This way the code is much **easier to maintain and reason about**. 

For an `if` with a complex condition it's hard to reason if the condition is correct (and exhaustive) in a sense of complying to the business requirements. 

In the example above (1st piece of code) we see that the code sends a message under some conditions. But what are those conditions and if they satisfy the business needs is hard to tell. 

In the refactored code we clearly see that message is sent only when sender is not receiver and either reservation matches or facility matches or sending is favored by the hotel.

Every time you assign a name to something you have a chance to think if the name describes that "something" correctly. So by just doing this rewrite you can identify the bug.

For the same reason, the refactored code is much **easier to debug**. When the `if` condition appears to be incorrect, you just put the breakpoint, and you immediately see the actual values of all sub-expressions. Therefore, you easily see which sub-expression gives incorrect result.

