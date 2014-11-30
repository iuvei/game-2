
„
packets.protomessage.packets"#
Packet
cmd (
body ("&
CSC_SysHeartBeat

servertime ("$
CS_Login
uid (
acc (	"Ý
SC_Login
success (
playerid (6
content (2%.message.packets.SC_Login.contentData
errCode (
errMsg (	Ô
contentData
aid (
sid (
name (	
exp (
level (
RMB (
money (

createTime (	
lastLoginTime	 (	
lastLogoutTime
 (	

max_vigour (
vigour ("
	CS_Logout"-
	SC_Logout
success (
errCode ("8
SC_MSG
errCode (
msg (	
showtype ("@
S2C_BroadCast
type (
times (:3
content (	"4
CS_AskCreateHero
playerid (
heroid ("L

SC_NewHero
result (.
heroinfo (2.message.packets.SC_HeroInfo"›
SC_HeroInfo
dataId (
GUID (
level (
quality (
stars (
exp (
favor (
armId (6
skills	 (2&.message.packets.SC_HeroInfo.skillinfo,
equips
 (2.message.packets.SC_ItemInfo.
	skillinfo

templateId (
level ("
CS_AskHeros
playerid ("\
SC_AskHeros
result (
playerid (+
heros (2.message.packets.SC_HeroInfo"$
CS_AskFormations
playerid ("1
SC_FormationInfo
index (
dataId ("I
SC_AskFormations5

formations (2!.message.packets.SC_FormationInfo"i
CS_UpdateFormation
playerid (
pos (4
	formation (2!.message.packets.SC_FormationInfo"\
SC_FormationResult
errocode (4
	formation (2!.message.packets.SC_FormationInfo"!
CS_AskItemBag
playerid ("¬
SC_AskItemBag
result (
playerid (5
items (2&.message.packets.SC_AskItemBag.ItemBagÁ
ItemBag,
equips (2.message.packets.SC_ItemInfo.
comitems (2.message.packets.SC_ItemInfo*
gems (2.message.packets.SC_ItemInfo,
debris (2.message.packets.SC_ItemInfo"4
CS_AskCreateItem
playerid (
dataid ("H

SC_NewItem
result (*
info (2.message.packets.SC_ItemInfo"H
SC_ItemInfo
dataId (
GUID (
num (
elevel (",

CS_UseItem
GUID (
HeroGUID ("t

SC_UseItem
result (*
item (2.message.packets.SC_ItemInfo*
hero (2.message.packets.SC_HeroInfo"7
CS_Compound
item_dataId (
hero_dataId ("}
SC_Compound
result (1
result_item (2.message.packets.SC_ItemInfo+
stuff (2.message.packets.SC_ItemInfo"5
CS_FightBegin
stageId (
client_time ("4
SC_FightBegin
stageId (

begin_time ("‡
CS_FightEnd
stageId (
win (
cbegin_time (
	cend_time (
round_count (
count (
all_hp ("Z
SC_FightEnd
stageId (
stars (+
award (2.message.packets.SC_ItemInfo