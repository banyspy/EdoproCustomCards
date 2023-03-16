# Banyspy EdoproCustomCards
This is repository contains custom card for Edopro script by banyspy.<br />
These cards are already test in Edopro.<br />

I do not own art that is use in this project. Most what I do is edited some of them to look like how I want.

## How to install custom card
First, you need to get the necessary files to the game folder.
You have 2 options to choose from.

<details open>
<summary>

### Method 1: Link to author github
</summary>
<p>

***This is a recommended method*** <br />
You will add link to github of this page in config so edopro know where to get data from.<br />

Some people may add the link to **configs.json** directly which work fine.<br />
Although I suggested to create **user_configs.json** in config folder in ProjectIgnis folder for the organized sake.<br />
When official edopro update the file, your data wouldn't get overwritten that way.<br />

The file location should be as shown below (Depend on device/OS).

``` .../ProjectIgnis/config/user_configs.json ```<br />
or<br />
``` .../EDOPro/config/user_configs.json ```

### If you dont have user_configs.json yet
because never created before, then download file [**here**](https://downgit.github.io/#/home?url=https://github.com/banyspy/EdoproCustomCards/blob/assets/user_configs.json), or manually create the file with the described name in directory and add the following description below to your file.
```json
{
   "repos": [
      {
         "url": "https://github.com/banyspy/EdoproCustomCards",
         "repo_name": "Banyspy Custom Card",
         "repo_path": "./repositories/Bankkyza",
         "should_update": true,
         "should_read": true
      }
	]
}
```
And that's finish for this step. If you do everything correctly.

<details>
<summary>

### Only if you already have user_configs.json before installing
</summary>
<p>

maybe because you download custom card from other people too, then add the following description below to your file, inside the **repos** bracket.
```json
  {
    "url": "https://github.com/banyspy/EdoproCustomCards",
    "repo_name": "Banyspy Custom Card",
    "repo_path": "./repositories/Bankkyza",
    "should_update": true,
    "should_read": true
  }
```
Don't forget to put **comma** to separate different link from each other.
It should look like this.
```json
{
   "repos": [
      {
      },
      {
         "url": "https://github.com/banyspy/EdoproCustomCards",
         "repo_name": "Banyspy Custom Card",
         "repo_path": "./repositories/Bankkyza",
         "should_update": true,
         "should_read": true
      },
      {
      }
	]
}
```
</p>
</details>

The benefit of this method is that the files that got pull from this repository will be **update every time game launch.** So the custom card in your client will be **update automatically** and **no need to come here to download again in case author update this repository.**<br />
However, if you can't do this method, for whatever the problem, you may try next method instead.
</p>
</details>

<details>
<summary> 

### Method 2: Download zip 
</summary>
<p>

![DownloadZipPic](https://github.com/banyspy/EdoproCustomCards/blob/assets/DownloadZipStepEdited.png)

 You can click on the green "code" button on the repository page then click **download zip** option.<br />
After download finish, you go to expansion folder in ProjectIgnis and then extract the downloaded zip file there.<br />
The expansion location should be as shown below (Depend on device/OS).

``` .../ProjectIgnis/expansions/ ```<br />
or<br />
``` .../EDOPro/expansions/ ```

And that should have made it<br />

However, if there is already duplicated existing file/folder there maybe because you also download custom card from other as well.<br />
For folders, Simply combined file inside the folder.<br />
For strings.conf, open them both and combined both content to one file.<br />
Then be hopeful that they are compatible with each other.

</p>
</details>

## How to use custom card

After you successfully got necessary files into directory, you can launch EDOPro to test the card.<br />
If you open the game before the installing process, close the game and open again, game only read database and repository at launch.<br />

![ShowRepositoryProgress](https://github.com/banyspy/EdoproCustomCards/blob/assets/RepositoryLoadingEdited.png)

*If you download zip to expansion, you can skip this and go to deck editor*<br />
After enter the game if you install by link with author github (user_configs.json), you can check at **Repository** button at top left and see if progress bar of **"Banyspy Custom Card"** is 100%.<br />
If it is 100% then it is good to go, you can check in deck editor.<br />
If it stay unfinished, may be checked if there is something wrong with user_configs.json file content or its location if you do it right like install guide, or any other factor that might affect.<br />

![ShowCustomCardFormat](https://github.com/banyspy/EdoproCustomCards/blob/assets/ShowCustomCardFormatEdited.png)

In deck editor, click at checkbox that is on the left of **"Alternative Formats"** to allow custom card in search filter and be able to use them in your deck and play test it.<br />
This is because custom cards are stored as **Custom format** card, as oppose to usual TCG or OCG, it is for the sake of organized.<br />

## How to actually play custom card

Beside from test the card in **"Test hand"** in Decks editor page. You can also play it in **LAN + AI** section in main menu.<br />

### Play against AI

Click **Host**, then in **Allowed card** section, click it to choose **Anything goes** in option list. Since custom card isn't legal card, it isn't allowed in any other format. That's all the requirement to play with AI, after that you just do anything that you would to play against AI in general. You can let AI play your custom card, but as you might expected, it would be able to play via premade **Fellin' Lucky** executor that has no logic but to choose YES to anything it can, which is to say, not so well.<br />

### Play against actual person

Same method of enable **Anything goes** in Allowed card section still apply, But you need to do something more as now you will play with other client that no longer on your own machine, unlike windbot.<br />
Here is method specified from official ProjectIgnis page.

>You have a couple of options:
>
>1) Port forward the LAN ports used by EDOPro and give your friend your IP to join in LAN mode.
>
>2) You and your friends can set up a VPN, such as [**Zerotier**](https://www.zerotier.com/), so everybody is on the same virtual LAN. Then you should be able to refresh the LAN room list or connect to the IP provided by the VPN. Both players must have the custom card databases to see what the cards are, and the hosting player must have the card scripts.


## Custom cards detail

You may find detail of custom cards in [**wiki**](https://github.com/banyspy/EdoproCustomCards/wiki).

## Progress

**Always take In-game text higher priority than card picture file while still in development phase, as editing text in database is alot more convenient than edit card text in card maker and render card picture and place it in folder**

**Magikular** - 15/15 - Finished.<br />
**Nethersea** - 12/12 - Finished.<br />
**Ancient Deep** - 6/6 - Finished. *(Actually there might be more)* <br />
**Zodragon** - 13/13 - Finished. <br />
**Reoyin** - 12/12 - Finished. *(Might be bug fixed abit in case there is but that's it)* <br />
**Traptrix** - 5-6/(10?) - On hold.<br />
**Sky striker** - 4/4 - Finished. *(Maybe there's more??)* <br />
**Malefic** - 4 - No real plan, side project from long time ago that decided to uploaded one that at least usable first, other will followed if polished enough.<br />
**Duel Altering** has no real progression goal, they are "cheat" kind of card for various intend not necessarily play normally, although would try to finish what created.<br />

### Planned Archetype

* **SoulForce** - Unconfirmed detail<br />
* **??**<br />

## Other people who also make custom cards

If you come here due to interest in using custom card, then you may interest to checkout other's custom card as well.<br />
So shout out to fellow scripted custom card maker!<br />
Here is who I found:

* [**Satellaa**](https://github.com/Satellaa/Custom-Cards)<br />
* [**Secuter**](https://github.com/Secuter/SecuterYGOCustomCards)<br />
* [**Henrique-Izidio**](https://github.com/Henrique-Izidio/EDOPro-RMS)<br />
* [**KServantes**](https://github.com/KServantes/Customs)<br />
* [**Neoyuno**](https://github.com/NeoYuno/leafbladie-cards)<br />
* [**scarletkc**](https://github.com/scarletkc/FogMoeYGO-Card-Database)<br />
* [**darkignister**](https://github.com/darkignister/edopro-kamenridercards)<br />
* [**supr3meofficial**](https://github.com/supr3meofficial/supremeygo)<br />
* [**NiiMiyo**](https://github.com/NiiMiyo/EDOPro-JJBA-Cards)<br />
* [**RayeHikawa227**](https://github.com/RayeHikawa227/xylen-scripts)<br />
* [**gabrielfandrade**](https://github.com/gabrielfandrade/Customs)<br />
* [**OmegaArmadillo**](https://github.com/OmegaArmadillo/EDOPro-Custom-Cards)<br />
* [**Rising Phoenix**](https://custom-ygo-rp.jimdofree.com/downloads/) **(Originally created for ygopro, beware of incompatibility issue)**<br />
