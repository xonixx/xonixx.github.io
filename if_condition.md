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
    || (hotelIds && hotelIds.contains(message.hotelId)) && (_hotelUser && message.type.toAllHotelUsers || reservationId && message.type.toAllReservations))
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
boolean messageAddressedToAll = _hotelUser && message.type.toAllHotelUsers || reservationId && message.type.toAllReservations
boolean shouldSendByHotel = hotelMatched && (messageAddressedToAll || isAdmin)
boolean senderIsNotReceiver = userId != message.authorId || message.authorId == null
boolean shouldSend = (reservationMatched || facilityMatched || shouldSendByHotel) && senderIsNotReceiver

if (shouldSend) {
    send(message)
}
```

What did we do? We split the complex expression to sub-expressions by giving them meaningful names.


