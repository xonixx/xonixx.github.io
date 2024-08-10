---
layout: post
title: 'TODO'
description: 'TODO'
image: TODO
---

# Don't use complex expressions in if condition

_August 2024_

```groovy
if ((((reservationId && statusMessage.reservationId == reservationId)
    || (facilityId && statusMessage.facilityId in facilityId)
    || (hotelIds && hotelIds.contains(statusMessage.hotelId)) && (_hotelUser && statusMessage.type.toAllHotelUsers || reservationId && statusMessage.type.toAllReservations))
    || (isAdmin && hotelIds.contains(statusMessage.hotelId))
    && (userId != statusMessage.authorId || statusMessage.authorId == null))
    && !(statusMessage.type.equals(ChatServiceMessageType.TicketComment) && userId == statusMessage.authorId)) 
{
    send(statusMessage)
}
```

```groovy
boolean reservationMatched = reservationId && statusMessage.reservationId == reservationId
boolean facilityMatched = facilityId && statusMessage.facilityId in facilityId
boolean hotelMatched = hotelIds && hotelIds.contains(statusMessage.hotelId)
boolean messageAddressedToAll = _hotelUser && statusMessage.type.toAllHotelUsers || reservationId && statusMessage.type.toAllReservations
boolean shouldSendByHotel = hotelMatched && (messageAddressedToAll || isAdmin)
boolean senderIsNotReceiver = userId != statusMessage.authorId || statusMessage.authorId == null
boolean shouldSend = (reservationMatched || facilityMatched || shouldSendByHotel) && senderIsNotReceiver

if (shouldSend) {
    send(statusMessage)
}

```

