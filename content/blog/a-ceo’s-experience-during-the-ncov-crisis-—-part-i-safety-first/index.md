---
title: A CEO’s Experience During the nCoV Crisis — Part I: Safety First
date: 2020-02-09
showAuthor: false
authors: 
  - teo-swee-ann
---
[Teo Swee Ann](https://medium.com/@teosweeann_65399?source=post_page-----c584a3fdddec--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F4c3c8300aca5&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fa-ceos-experience-during-the-ncov-crisis-part-i-safety-first-c584a3fdddec&user=Teo+Swee+Ann&userId=4c3c8300aca5&source=post_page-4c3c8300aca5----c584a3fdddec---------------------post_header-----------)

--

*As Espressif is a company with their main offices in China, the recent coronavirus outbreak has affected us as well. Even though there is an obvious impact on the way we work, the blow is cushioned because we have offices outside of China. Additionally, the way our IT is structured allows most of our staff to work from home, and even for the jobs that do need people to be at the office, there are ways to work around the current issues. CEO Teo Swee Ann gives some insight the thought process behind the decisions made.*

It was approaching Chinese New Year. I had just left for Okinawa on 24th Jan 2020, from Shanghai with my family — a planned vacation during the Chinese New Year celebration that we were looking forward to. In fact, it had been more than 2 years, since I last had a holiday together with my family.

However, it was to be a holiday that wasn’t meant to be. The coronavirus outbreak situation in China was developing rapidly: just a day ago, Wuhan was locked down and the news reported that there is human-human transmission of the coronavirus. Still at that point of time, most people thought that it was going to blow over soon, and it wasn’t not that bad. It was said to be no more dangerous than a common flu and to only affect the elderly, albeit highly contagious.

> Many things went through my mind on the plane en route to Okinawa. As I watch the clouds floating by, from my window seat, I wondered how the virus will spread in in China, when it would be over, would it affect our colleagues in China, how many days of delay would this be? I had optimistically thought that it would blow over within a month.

## Safety First

As with all new problems, we need to first establish the facts and consider what our alternatives are. Once I landed in Okinawa and checked into the hotel, I immediately called for an online meeting with our China management team to discuss and gather what we know. First, we knew that it was infectious. Second, the mortality rate wasn’t too high. Third, the virus was only fatal to people who were aged or had pre-existing conditions. Of concern, we have some staff who fall within the susceptible age group.

Based on these information, we formulated our base case and decided to push back the start date of the company to the 3rd of Feb instead of the 30th of Jan (which was later pushed back to the 17th). With this established, we then considered the extreme case: what if nCoV-2019 is the biological equivalent of a nuclear holocaust; with a couple of mutations, it acquires a mortality rate like that of MERS (70%) and is highly infectious?

> Could we move our staff out of harm’s way?

The discussion was long and no one was sure how serious it is. Should we wait for the government to make an announcement? Should we panic? We finally decided that we should err on the side of caution, and pro-actively mitigate our risks. For the case of our expat staff, working in Shanghai, we would move them overseas, because many of the group do not speak Chinese and are relatively older. In the case of an emergency, the language barrier may severely disadvantage them.

> We also knew that when we move our colleagues from Shanghai to another country, we could possibly exacerbate the situation, by spreading it to other countries. How do we square this risk with the considerations about the safety of our colleagues? I made the decision that we should look at the facts as they were: was Shanghai being quarantined? No. Do I think that our staff were infected or exposed? I don’t know everything but I think no — our colleagues were not in Wuhan, or had contact with people from Wuhan. Do I think we should move as many people as we could as long as the laws do not bar us from doing so, our staff are symptoms free and do not have exposure to Wuhan? Yes.

On the 27th, we had most of our expat staff leave Shanghai for their home countries with instructions to self-quarantine themselves for at least 10 days thereafter. One of our directors stayed put in Shanghai because his child has flu-like symptoms.

How about our local staff in China? First of all, everyone has families in China and naturally everyone wants to be with their family. We briefly considered moving our staff to a warmer climate (within China), such as balmy Hainan (an island in southern China) — it was theorized in the previous SARS outbreak that hot climate and high humidity may have helped stemmed the outbreaks in some regions. After a long exchange, we came to a conclusion that the best course of action was to stay put. Most Chinese cities such as Shanghai, Suzhou and Wuxi, where most of our staff are located, have good medical resource; the Chinese government was also taking a vigorous response to the crisis — the plan to impose strict quarantine on entire major cities and making use of the Chinese New Year to isolate every household is unprecedented in scope and audacity.

The early intervention and coordination of the Chinese central government have played a huge role in reining in the spread of the virus to the other Chinese cities and countries, giving everyone precious time to prepare for this contagion. While there have had been criticism of the initial handling of the Chinese government of this crisis, I am of the opinion that the Chinese central government has responded decisively and swiftly once they had gathered the information.

## Situational Analysis

## Chip Production

Based on the feedback from our supply chain and logistics partners, our chip supply functions are unaffected. On the silicon wafer side, our associate foundries are located in Taiwan and unaffected. Our partner module factories in China will be resume operations on the 10th of February.

Our current considerations are how we could without endangering our colleagues and our partners, fulfill the needs of our customers. We note that our manufacturing partners have automated processes that require very little physical workforce. However, we will have another review of our manufacturing processes and supply chain over the next 1 week as we obtain new data from and continue to build new contingencies.

## New Product and Customer Support

After we moved some of our colleagues out of China, we would regroup everyone in our Czech and Indian offices to proceed with the launch of our new product, ESP32-S2. The R&D of ESP-IDF, solutions frameworks and customer support from these sites are not affected.

## Chip R&D

About 40% of our staff in China are issued with laptops and can work from home without any issues.

The majority of the chip design is done in our China offices and this year, we have completed and verified major pieces of our core IPs (some of which are used in ESP32-S2) and we are just finishing up on our integration for ESP32-S3 and ESP32-C2. While there is some impact on chip R&D due to the need to access simulation servers, this can be mitigated by enabling remote access.

Based on our current estimates, more than 90% of our staff will be back and ready to get back to work within 14 days from now, either physically or via remote access. We are also preparing to have *all* our staff work online, in the event that the situation turns for the worse.

## Contingencies and Questions

Over the past two weeks, our global management team has formed the business contingencies, created a new emergency response team (ERT) and carefully evaluated all of the functions of our groups. When formulating the contingencies, we have to make sure that they are real contingencies for the worst case scenarios, including what if I and the management team were infected and down. Although the chances of this happening is extremely small, but we still have to consider these scenarios — things can be unpredictable.

While our aims are to restore the full function of the company as soon as possible, we have to put the safety of our staff at first place. There are certain functions of the company which will require the physical presence of our staff. How do we evaluate the risk?

First, the risk of spreading an infection is described by the following equation:

*probability*[spread at least 1 new infection] = 1 — (1 — 𝜹) ^ ( *N*[interactions] ⨉ *N*[infected] )

where 𝜹 is the probability of spreading the virus with each interaction, *N*[interaction] is the number of direct interactions each infected person has with other non-infected people in one epoch (we define as 5 days), and *N*[infected] is the number of infected people in the group. (95% of the population develop symptoms when infected, within 5 days.)

If any of the values: 𝜹, *N*[interactions] or *N*[infected] is equal to zero, there would be no chance of spreading the infection. Hence, to minimize the risks of spreading any infection within the company, we then have to do these 3 groups of actions:

## More on Reducing Infectivity (or 𝜹)

Here’s our list of recommendations:

## Practical Questions

## The Situation in Wuhan

As we have learnt, the situation in Wuhan is critical. Medical staff are getting infected and falling sick. The frontline medical workers are putting their lives at stake to battle the disease. There are even some who have died not of the disease but of exhaustion. The central government is sending thousands of medical workers to Wuhan to relieve the crisis. As of today (10 Feb 2020), the number of new infections in Wuhan are on a downward trend.

## What Next

In this epidemic, we are currently in unknown territory; we do not know how the situation will develop or the outcome. Experts have commented that with a R0 that is greater than 2.5, it would probably become a pandemic. But these may not be taking into account the drastic quarantine measures in China. These quarantine measures could also possibly keep the infection rates low enough to buy some time, till warmer weather eliminates the virus.

> Based on the current statistics, the mortality rates outside of Wuhan is 0.2%. This could be no worse than a bad influenza, which has a mortality rate of 0.1%?

We have taken measures to keep Espressif going and to keep everyone within Espressif healthy to fight another day. Espressif Czech and Espressif India are unaffected and continue to support our customers directly and develop our latest solutions. In case the situation deteriorates, we will have our entire China workforce to work from home.

We are also ready to contribute to the fight against the virus with IOT technology, such with our low cost AI enabled voice recognition (hands free) solution ESP-SKAÏNET and soon to be announced ESP-RAINMAKER. __@Makers, please share your ideas!__  We will help support any IOT solutions that help control the epidemic.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*IHIIR1okx8QRo-EOX0MyZQ.png)

Teo Swee Ann, CEO Espressif Systems

10 Feb 2020
