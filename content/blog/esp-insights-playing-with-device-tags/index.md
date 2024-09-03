---
title: ESP Insights: Playing with Device Tags
date: 2022-09-07
showAuthor: false
authors: 
  - adwait-patankar
---
[Adwait Patankar](https://medium.com/@adwaitpatankar?source=post_page-----ece2c3691712--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2Fb31acf34f5e6&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fesp-insights-playing-with-device-tags-ece2c3691712&user=Adwait+Patankar&userId=b31acf34f5e6&source=post_page-b31acf34f5e6----ece2c3691712---------------------post_header-----------)

--

In today’s world which is completely engulfed in social media, the notion of tags is not new. Most of the media publicly shared on the social network is tagged (or to be more accurate, hash-tagged) with something or the other. With that familiarity in mind, we thought of introducing the concept of tagging to the ESP devices, that should help users categorise or search their devices faster on the ESP Insights Dashboard.

## What is tagging?

A tag is essentially a label, that makes the object or thing being tagged easier to find or categorise. In the social media world it is called as hashtag that is applied to a post, image, video or rather any media content based on the information it carries or sometimes based on specific theme. For e.g. #summervibes #sunnyday

## Device Tagging

In IOT world too, how cool it would be to label your devices with such tags. The tag can be associated as a meta-data with the device and would certainly help in searching, categorising your devices in the field. We maintain tags as a combination of Name-Value pair to add a multi-dimensional categorization.

For e.g. If user wants to tag the devices based on their location viz. City:Boston or within a home automation project say Location:Kitchen for a smart bulb in the kitchen and so on so forth.

If the devices are to be categorised based on the firmware version viz. Version:v5.1 or based on their behaviour like infrequent crashing viz. Category:Crashing.

The image below showcases how the device level tags (if applied) are enlisted on the node reports page below the stats section.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*WIAp-dVfYF3SLebYtnipMQ.png)

Click on any of the listed tags, user is taken to the Group Analytics page with an automatic search filter applied for the the clicked tag name. All the devices carrying the selected tag are displayed in the nodes listing.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*hZPHeMOzuY3lsH1qAZHtBg.png)

As mentioned earlier, the users can also explicitly apply search filters based on node tags from the Group Analytics Dynamic Search Filters and list out device matching the search criteria. For e.g. Search all devices of type bulb.

The *Property* input box also supports auto-suggest based on the available tags as applied to the devices of the logged-in user. The *Value* input box also supports auto-suggest based on the values already present for the selected tag property.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*zg043paVaojRGs4aainVjQ.png)

## Tag Management

Now that we know we know that the users can tag their own devices, let’s take a look at how to actually add tags to the devices from the ESP Insights Dashboard. At this moment, tags can only be applied one device (a.k.a node) at a time, by accessing the individual node details. User can reach to an individual node by selecting one of their nodes from the node list accessed either via “Nodes” option or a filtered node list from “Group Analytics” option.

On the selected node, now the users should see a new tab called “__*Tags*__ ” along side the Node Report, Metrics and Variables tabs.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*Oz7_fZ2eWCJZWftDg1BVKg.png)

The __*Tags*__  tab enlists all the existing tags. User is able to add or remove tags from this page. The tag is added or removed only for the selected node.

User has to enter a combination of Tag Name and Tag Value. Both of these are case-sensitive and each input field has a restriction of 15 characters.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*zkkbXVvfFaIF4IdgwZGgoA.png)

There is a ‘Delete’ option available in front of the each listed tag. User can delete or disassociate one tag at a time.

Stay tuned to get more on what we can achieve with the tagging feature especially with the search and grouping of devices based on the tags.

Visit [https://dashboard.insights.espressif.com](https://dashboard.insights.espressif.com) to play around with tags on your devices.
