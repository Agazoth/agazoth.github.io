---
layout: post
title: "Microsoft Partner Token Issues"
date:   2023-05-26 08:00:28 +0000
categories: blogpost
---


When working with the Partner Center API, you sometimes stumble upon some very obscure documentation.

Due to recent progressions in our current project, I found this again, after having forgotten all about it in many sprints:

![TokenToPartnerCenter]({{ site.url }}/images/tokenToPartnerCenter.png)

[Link to page (contents might change)](https://learn.microsoft.com/en-us/partner-center/developer/get-delegated-admin-relation-statistics)

I remember that, many sprints ago, I tried to generate this token. Looking back in my repos, I found the code that made it generate a valid token.

The trained eye quickly realizes, that the first line (the one beginning with POST) is the uri you have to call to get the token.

Logic dictates, that the rest must be the body.

When assessing the body for the call, it springs to mind, that the variations of = and : are probably going to cause some issues.

To keep this short and to the point in a language most tech-shavvy people understand, the correct documentation could be written like:

```powershell
$Uri = 'https://login.microsoftonline.com/<partner_tenant_id>/oauth2/token'
$Body = 'grant_type=client_credentials&scope=https://api.partnercustomeradministration.microsoft.com&client_id=<client_id>&client_secret=<client_secret>' # notice that the :'s have been replaced by ='s like in the first part of the original documentation
Invoke-RestMethod -Uri $Uri -Body $Body -Method Post
```

If you followed proceeding documentation in the link to the point, the above code provides you with a beautyful token.

Unfortunately, the token does not work for the rest of the calls in the article.