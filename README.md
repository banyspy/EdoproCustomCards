# Hello there
This is repository contains custom card for Edopro made by banyspy.<br />
These cards are already test in Edopro.

## How to use custom card
You have 2 options to choose from, choose one that is more convenient for you.
<details open>
<summary> 

### 1.Download zip 
</summary>
<p>
 You can click on the green "code" button on the repository page then click **download zip** option.<br />
After download finish, you go to expansion folder in ProjectIgnis and then extract the downloaded zip file there.<br />
The expansion location should be as shown below.

``` .../ProjectIgnis/expansions/ ```

And that should have made it<br />

However, if there is already duplicated existing file/folder there maybe because you also download custom card from other as well.<br />
For folders, Simply combined file inside the folder.<br />
For strings.conf, open them both and combined both content to one file.<br />
Then be hopeful that they are compatible with each other.

</p>
</details>
<details open>
<summary>

### 2. Connect to author github
</summary>
<p>
You will add link to github of this page in config so edopro know where to get data from.

Some people may add the link to **configs.json** directly which work fine.<br />
Although I suggested to create **user_configs.json** in config folder in ProjectIgnis folder for the organized sake.<br />
When official edopro update the file, your data wouldn't get overwritten that way.<br />

The file location should be as shown below.

``` .../ProjectIgnis/config/user_configs.json ```

### If you dont have user_configs.json yet
because never created before, then create the file with the described name in directory and add the following description below to your file.
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
</p>
</details>

## Custom cards detail

You may find detail of custom cards in wiki.

## Progress
Incomplete for now. More card and fix to existing card to come.
There is also more archetype but I don't push it until I test it enough.
