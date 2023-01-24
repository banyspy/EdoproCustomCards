# Banyspy EdoproCustomCards
This is repository contains custom card for Edopro made by banyspy.<br />
These cards are already test in Edopro.

## How to install custom card
First, you need to get the necessary files to the game folder.
You have 2 options to choose from.

<details open>
<summary>

### Method 1: Connect to author github
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

### If you already have user_configs.json
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
The benefit of this method is that the files that got pull from this repository will be **update every time game launch.** So the custom card in your client will be **update automatically** and **no need to come here to download again.**<br />
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

## Custom cards detail

You may find detail of custom cards in [**wiki**](https://github.com/banyspy/EdoproCustomCards/wiki).

## Progress
Incomplete for now. Some of uploaded card isn't even finished making (as can see from card text). More card and fix to existing card to come.
There is also more archetype but I don't push it until I test it enough.
