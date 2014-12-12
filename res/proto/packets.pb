
ù
packets.protomessage.packets"#
Packet
cmd (
body ("&
CSC_SysHeartBeat

servertime ("$
CS_Login
uid (
acc (	"ß
SC_Login
success (
playerid (6
content (2%.message.packets.SC_Login.contentData
errCode (
errMsg (	û
contentData
aid (
sid (
name (	
exp (
level (
RMB (
money (

max_vigour (
vigour	 (
rvt
 ("

CS_AskInfo
type ("

CS_Command
content (	"8
SC_MSG
errCode (
msg (	
showtype ("?
SC_BroadCast
type (
times (:3
content (	"L

SC_NewHero
result (.
heroinfo (2.message.packets.SC_HeroInfo"õ
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
level ("J
SC_AskHeros
result (+
heros (2.message.packets.SC_HeroInfo"1
SC_FormationInfo
index (
dataId ("I
SC_AskFormations5

formations (2!.message.packets.SC_FormationInfo"W
CS_UpdateFormation
pos (4
	formation (2!.message.packets.SC_FormationInfo"\
SC_FormationResult
errocode (4
	formation (2!.message.packets.SC_FormationInfo" 
SC_AskItemBag
result (5
items (2&.message.packets.SC_AskItemBag.ItemBagÒ
ItemBag,
equips (2.message.packets.SC_ItemInfo.
comitems (2.message.packets.SC_ItemInfo.
material (2.message.packets.SC_ItemInfo*
gems (2.message.packets.SC_ItemInfo,
debris (2.message.packets.SC_ItemInfo"H

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
stuff (2.message.packets.SC_ItemInfo"8
CS_EquipEnhance
	hero_guid (

equip_guid ("!
SC_EquipEnhance
result ("T
SC_UpdateHeroEquip
	hero_guid (+
equip (2.message.packets.SC_ItemInfo"Ç
SC_UpdateKeys
	hero_guid (5
kvs (2(.message.packets.SC_UpdateKeys.key_value'
	key_value
key (	
value ("=
SC_AskStages-
stages (2.message.packets.SC_StageInfo"8
SC_StageInfo

Id (
count (
stars ("5
CS_FightBegin
stageId (
client_time ("0
SC_FightBegin
stageId (
result ("á
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