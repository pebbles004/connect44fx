<map version="0.8.1">
<!-- To view this file, download free mind mapping software FreeMind from http://freemind.sourceforge.net -->
<node CREATED="1257623626459" ID="Freemind_Link_357652419" MODIFIED="1257623634665" TEXT="Connect44FX">
<node CREATED="1257623676702" ID="Freemind_Link_1591407363" MODIFIED="1257624363597" POSITION="left" TEXT="behavior">
<node CREATED="1257623700801" ID="Freemind_Link_881837588" MODIFIED="1257623733253" TEXT="Levels">
<node CREATED="1257623971521" ID="Freemind_Link_1916393404" MODIFIED="1257623980229" TEXT="Increased difficulties">
<node CREATED="1257623879081" ID="Freemind_Link_1836238740" MODIFIED="1257623994877" TEXT="AI gets smarter and faster with each level"/>
<node CREATED="1257624027969" ID="Freemind_Link_501524910" MODIFIED="1257624041309" TEXT="Grid expands"/>
<node CREATED="1257624042201" ID="Freemind_Link_1081432159" MODIFIED="1257624054637" TEXT="maximum reflection time"/>
<node CREATED="1257624057569" ID="Freemind_Link_949411122" MODIFIED="1257624100741" TEXT="increasing number of aligned coins needed to win"/>
<node CREATED="1257624458177" ID="Freemind_Link_284013556" MODIFIED="1257624468143" TEXT="fancy modifiers">
<icon BUILTIN="help"/>
<node CREATED="1257624472718" ID="Freemind_Link_436174174" MODIFIED="1257624487013" TEXT="change sides (red becomes blue &amp; inverse)"/>
<node CREATED="1257624488801" ID="Freemind_Link_1411064678" MODIFIED="1257624502717" TEXT="exploding coins"/>
<node CREATED="1257624510994" ID="Freemind_Link_827765710" MODIFIED="1257624519165" TEXT="frozen cells"/>
</node>
</node>
<node CREATED="1257623756962" ID="Freemind_Link_394032975" MODIFIED="1257623786309" TEXT="Score = Levels won + time played"/>
</node>
<node CREATED="1257623905785" ID="Freemind_Link_1164325967" MODIFIED="1257623910797" TEXT="game">
<node CREATED="1257623912441" ID="Freemind_Link_1911851049" MODIFIED="1257623919269" TEXT="starts at level 0"/>
<node CREATED="1257623931185" ID="Freemind_Link_642285438" MODIFIED="1257623960741" TEXT="each won level gives access to next"/>
<node CREATED="1257623921601" ID="Freemind_Link_769090492" MODIFIED="1257624310703" TEXT="doesn&apos;t end - levels are generated on the fly">
<icon BUILTIN="help"/>
</node>
</node>
<node CREATED="1257623734145" ID="Freemind_Link_380366406" MODIFIED="1257623753605" TEXT="Human vs AI"/>
<node CREATED="1257624182249" ID="Freemind_Link_274512120" MODIFIED="1257624185653" TEXT="score">
<node CREATED="1257624188913" ID="Freemind_Link_1120010806" MODIFIED="1257624199877" TEXT="is submitted to server when lost"/>
<node CREATED="1257624230737" ID="Freemind_Link_170446494" MODIFIED="1257624253365" TEXT="send a message to player facebook account"/>
<node CREATED="1257624254641" ID="Freemind_Link_1159706736" MODIFIED="1257624282813" TEXT="send a message to players being beaten"/>
</node>
</node>
<node CREATED="1257624330270" ID="Freemind_Link_726338234" MODIFIED="1257624351309" POSITION="right" TEXT="looks">
<node CREATED="1257624385910" ID="Freemind_Link_1216528672" MODIFIED="1257624401637" TEXT="skin for grid - if possible for each level"/>
<node CREATED="1257624402993" ID="Freemind_Link_1517548458" MODIFIED="1257624408245" TEXT="skin for coins"/>
<node CREATED="1257624409041" ID="Freemind_Link_1121387582" MODIFIED="1257624423477" TEXT="coins fall down animation"/>
<node CREATED="1257624425297" ID="Freemind_Link_213289994" MODIFIED="1257624550117" TEXT="scores &amp; names &amp; picture of players"/>
<node CREATED="1257624557881" ID="Freemind_Link_78097435" MODIFIED="1257624569141" TEXT="drag and drop coins from a pile of coins"/>
<node CREATED="1257624595962" ID="Freemind_Link_1479248354" MODIFIED="1257624603813" TEXT="level won animation"/>
<node CREATED="1257624604385" ID="Freemind_Link_1615458390" MODIFIED="1257624610397" TEXT="lost animation"/>
<node CREATED="1257624610809" ID="Freemind_Link_105263902" MODIFIED="1257624644165" TEXT="submit score to server dialog"/>
<node CREATED="1257624794801" ID="Freemind_Link_503905832" MODIFIED="1257624809741" TEXT="start game dialog"/>
<node CREATED="1257624723601" ID="Freemind_Link_1092903522" MODIFIED="1257624747567" TEXT="Graphics are done with graphics applications">
<icon BUILTIN="messagebox_warning"/>
</node>
</node>
<node CREATED="1257624821918" ID="Freemind_Link_1633121328" MODIFIED="1257624834757" POSITION="left" TEXT="architecture">
<node CREATED="1257624837969" ID="Freemind_Link_1876456714" MODIFIED="1257624845197" TEXT="server side application">
<node CREATED="1257624885234" ID="Freemind_Link_75540198" MODIFIED="1257624891893" TEXT="google app engine"/>
<node CREATED="1257624894570" ID="Freemind_Link_225226033" MODIFIED="1257624904157" TEXT="keeps score"/>
<node CREATED="1257624904817" ID="Freemind_Link_1060835534" MODIFIED="1257624913885" TEXT="dispatches messages to facebook users"/>
</node>
<node CREATED="1257624846458" ID="Freemind_Link_762763123" MODIFIED="1257624854589" TEXT="client game application">
<node CREATED="1257624857834" ID="Freemind_Link_1669085484" MODIFIED="1257624861797" TEXT="javaFX applet"/>
<node CREATED="1257679626137" ID="Freemind_Link_1605309980" MODIFIED="1257679633389" TEXT="deployed with server application"/>
<node CREATED="1257623645186" ID="_" MODIFIED="1257623670314" TEXT="SSO with FaceBook">
<icon BUILTIN="help"/>
</node>
</node>
<node CREATED="1257679637912" ID="Freemind_Link_1350585862" MODIFIED="1257679653062" TEXT="Maven JavaFX plaugin">
<icon BUILTIN="help"/>
</node>
</node>
</node>
</map>
