import
  strutils, sequtils, algorithm

const
  text = """
Even with the rough edges, expected in a programming language which hasn't yet
reached version 1.0 and is already running circles around established
programming languages, macros are a complete win for programming. They allow
you to become a compiler developer and extend the language just that little bit
in the direction you need to make your life easier. Only without the pain and
embarrassment of pull requests being reviewed and rejected. And let's face it,
figuring out how macros work and how to write them is in itself a fun exercise.

I'd also like to thank the wonderful Ace of Angels for their performances and
the dozens of Korean camera men offering high quality captures of them. They
were crucial to overcome the hurdles mentioned above. At times of difficulty,
clearing your mind of thoughts by looking at something else can help. More so
if what you are looking at inspires you to keep working. Ace of Angels,
fighting!
"""

  urls = """

-i_2DIGBmO4
-uZj3EVuSiM
1KMF2cDG-Aw
22vDm0JSc7E
27Cs_W5EptU
2KYQH2a5u-Y
2KtflWoHIeE
2TxSSILNibY
2w-nmLcZUFA
2x_4Odo8BzI
39B3AeTD0lY
3Tw-90vdfnQ
43dbZq6bv1o
4ZBDWpneAgw
4oL9XLCktOQ
58xk5L5pCMg
5P7QGBIFAgo
5XHEgyNZPQA
6JhZhMYx780
6_HHut7u29w
6hqSmVRXwTE
85kgIuq3HY4
8NFXElCZY4I
91FleKcgKbE
9g2YPmzDfkI
A_MCEHd6now
Ac7SN63L6po
B99pOzAfFy4
BygwsVYUbO8
CTAAn5vbVPs
D0TkSCpBSc0
DBNAWLlPxCY
DO8SJ2uxV4s
Dgwth72XZCQ
EDxOSsiaEYU
FAeu3esj1nM
FnxEUBZ-9WY
G2r5KVosjIw
GnJ1KMY_k_M
Gnsjy8lpIH8
HIymqJtD3fw
Hpp4mXPihZg
Htjh6Vyxkws
Hxxoyc05hWQ
IJDckhfF0Z4
J9_rfRC49P0
JfBzQQ12W5M
KCfyNlp7rmw
KYwyzTFQ_W4
Kf-naZmRJoI
KvfmywBHNaI
L-I0o5bB0D0
LRnblsA54ZI
MQ2sOfXhr3I
MX4JXqOCcTs
MrTrlRLAH-s
Mwf6jxUBU0Q
NTEOMaXxc3w
NWD3C0ax-ZY
NeAgohY9hqM
tQZlwr1JQ1Q
tZYJXI93RCw
thabOb8WX34
uwhZgR2Wuew
v7cpVcnrPu4
wyIC3Z0_9J8
x7cMdxp49XQ
xpbs6SRQsTI
xqmjmR-vRP0
xryLWlBfXa0
yku6QKz6Drc
zWi9Vk77bkY
zp5CwgMSOMU
O0srg6Lgzgg
OOejPz9kV6I
PA-mnyNU8VE
PMgZ5gia64U
Pxb7KAbADf0
QUYILpXU1eQ
QpAimvj3PFs
QtRKy7uEYks
Qwr_aRE-PRw
R7pfg5E-JQ4
RCybFtD9ROg
Rie4knPIKPw
RjwjFmfLfps
SQq8lPtK65g

dQw4w9WgXcQ

SnmUALfrJMw
TUrxPOF9kZs
UzkAGgBDHTM
VDJRMjtzvlg
V_lvh4HuOKA
Vdd-z87h0Ek
WHTqrECQZyw
WyN7uzv55Qs
XSxbmpBMz0E
XfXZcXOCKNg
Xl_2aOOpTmg
Y4l0vyLEQ8g
Y6JVsIiMLyU
YLnZWkMUKRA
YsxKBvJFtuU
YvnlMaYUe24
ZiRcTCfAjdM
ZpgTevBUStE
_2oVTghzm5I
_39a5TJC47E
_9l_xrpg9J4
_HizAsI9KnM
_R1W21n5f74
_sBtnpRE4r0
_xSixaY-KKE
aJ0cBPTZugo
afgWZGd-3gg
arx-pq-7Z1o
bQ3XlIQyPEI
biCkA4q2_FE
chkdylyKgJE
dC2iOh831Jg
dCDij8E7fwo
dLTSeAiPK34
d_SO284MFfs
eK3KJ7AlxNs
ePuj3g2giUY
f0uY0zFG0y8
fLZG31_AKsQ
fZ8ebCBb8z4
haOvfeui2K0
i0jDsG94m90
iAertuXKvnc
iG7sb6PlbeQ
k8K7SDf54LY
lBbC5L2p5gM
l_eNMOFXcM8
ljwkRDdhjVM
lrzPvetaDUY
mCFIWB_gIBQ
mG_UY_SCKqg
mSinameBSN0
n3cZIdMd5QM
nflUbvqSgMU
nkHPrIJtAD8
o2Rx2TeErho
o4Wa7nwB29M
oG48HRGe5LA
ojvES51dOUY
ooJiMFG-Uuo
otJ8jzIBtMM
ozDnGDxh7ZA
pW7NSL9STp4
qeOycPTKbl0
qgen0Hv4rBk
r-4_j1V6frE
r4jFOB0cu6s
s1StWjh0oFo
sQdoijEyc3g
sbG87-GbQWM
stBjpAXjRpY
t4b2Zb67_Ro
"""

  extra = """

weqhr9PaSG0
Lm-x444gSOk
Rkk-_Auv6hI
aHOt9makl2o
EAglVLW_99E
ITDp7Z7s6gs
7HFwjrrPx7A
EZ487LebWt8
1xKE1H8BXmE
llWWXuY52v4
6yWl2DX3-gY
Ma2Hr0sb5jw
-Pk5Mgby5MM
L_yV2-bWXwI
RYCuH5aargc
phKycO8cssg
P_eywF1ATFQ
SUibrPIhQvY
JsQjs-mQ-Ko
vvpMLSFxnOs
VlPd3pxtYds
CpUPKf6LGeU
Ecl-evf8Jxk
bKWvI5eO63A
qDRq1yN5N5o
xiW5OFlh0no
Q3nmQBcAn34
_x2aPpEew6M
2E3Bx7R8ubA
gKU7xvv5fdQ
I9CcyTfHn6M
X6E03oOB3HE
aD2aOIpY-gs
Yx0OX4ZI6BY
twqt32inx40
E_rv646M9D0
tm2JdbDC-yI
uf4BSbOGZm4
XGXKdKWagpA
Avx5Gd8oqUE
CVe7DJGTNLE
bfrzrXBSmtg
2xUGR8uMHF0
S_viRBsGHGA
q0VAkP-px4A
xb3bVimJLmU
1UbHDrQvCfw
azPCcUJKkSw
dbmJRkmCML4
DmDHtLCB35I
iMgcW-VaOiU
d8Bpbg4_AFE
uIStOWvqtT0
0DT0uXqDw90
Sdaeqnl-Kr8
eWvwpdmgtGo
pDq0tNSDmM4
wV-EPbe0DuI
OgvKiuNfjhY
CSeXtFzG_lw
GEcJsDm-CxI
bPMTSUmX5ts
tgE8WphiJ9o
oAWs2JOxdaI
3EZxfsETRO4
5PVXAYMUt9s
dZI38I1ou5s
3VeTO1xK5tY
IIqTOXke0us
PUyMi9ST4dg
IRRZtA8AQ_I
kzquiltqQHc
UrEJYuuw2-g
_YCjISB9EFs
PBHwW5PvhU8
3JZHErbfNO8
WwyAzrin3Ak
_BSIpshmGTM
HtxpEg_P6mA
XR9HJTOBfJo
ePVMfbfM2Ac
EhJrE2WAUzc
PFzchE7qI7U
CE-0btDtQGo
rqFxDqpoaaA
P5c_eCefPco
RSfIOw60XEs
RoLj1q9IJos
R4eZFbnPTdo
zXkJuPUzVME
R4--4OvrosY
4JuOmjG4XiM
u8tYYUCmySE
y4arsoeFg_Y
BuFRnvasr10
P5EODlCe8o8
gMLzYmEOe0U
zCPA4rbSTdc
h81H5K84Xmc
J35pWF82PQs
CruHW6ozTfM
N3PlYwRFprs
V_fMQWe_cuI
ba8_ZW78HUc
S_llYbRVrBA
S_fBRYxgAh4
qa-cMwzRX8Y
EkGFpoy3dVc
_z-NEVTwRGQ
H4E-c2Njazk
Jd_MaA2WAKg
84Q-V78Y75E
nq_rMwNzPho
HcOXSIDZMMA
cNqNlxXvI6k
jwr6ZJWyX7g
tbL20fOug3E
rSW2fI4YcLQ
2VkE-TKJFTs
l3nuqmxJPCI
tjLyy56fBRM
S39jRVLI41M
zcxEjCT4LXo
vNFq8hTNHAg
kTCedCwD7vI
Mpgb-Uj8fY8
NuabKNGU-Zg
rcenl_5FqoE
4iqb28juYcI
2nbgklKJCks
i1vmyjeWFgY
PHPcwJapmY8
0pzi24oYnOc
wNtURCw8aR0
ZbbPS_FEb6M
CsndL8wMxmI
mwNDdnPc-yw
JhW2J_ThnX8
raI-kZpy7DY
TUvXAw_Qmrw
_Qu03pcNvxc
27-84EI_zfo
HcK6UqfaaxQ
D0QZdbOVELU
sGzaer4eYLQ
uHKWh67ZeXk
vPj2eW-Dpco
fh6Q2Hdmj_Y
hNURQZobj8c
cvYdng46CW8
dXV_I_UZ0l0
E872pzZibrY
NY6mIA_BpRs
cZVD6q26P3g
lkEbzZGURAg
-3LAlqZ6ygg
3NyQBNI0HF0
Gr_jN10_QKc
IX8CFSJFz-Y
J3Kd7uH4wiQ
Ve1lMpZsc5c
YCfVsVwbogw
Yr2Vo9s4yGk
YtM5BHavD-E
_a6wwpSNkqc
ekpzzyxYREU
gClRSBqyBFY
hpj_A6Cew4M
iJkYk7Id7KY
icf-ZYZ6mwk
l_RpDbxafaw
r1ssXaaPBUI
setjkZjrj1A
v5-x1NpXJ7Y
vvsl8_oLdd0
xhcfov1ev6U
yVfgmy9Z8Q0
FNiA2cbbRXc
l2i_g5USm-g
CrT1rOaYN6c
av8DtcuWMDs

IMd9f7aNYNM
g_-5iCrlLzQ
iJKoR1BYsqg
vc4SxgbzfSc
49KCnhmycS8
f-lI2g8lAF0
4_DsoAfbvlo
xMk0s8UXWno
phLfv8-AOBM
iDRtPsP7EnQ
3DfGkxo2RN0
HutecEymnIo
8dPDHjQVpjY
n0gEft3pmT0
0-AyEdLch18
EKrRK7LfSYU
clJi5dzv9UA
BnBteCSirIk
a95OCbjE9YQ
xZ1s3ePWQUA
BgyoBC05MeY
E4TygUpWUTQ

"""

proc main() =
  var links: seq[string] = @[]
  for url in urls.split:
    links.add("http://www.youtube.com/watch?v=" & url)

  var
    total_words = text.split
    total_links = total_words

  #echo "Got ", total_words.len, " words, and ", links.len, " urls."
  assert total_words.len <= links.len

  for f in 0 .. <total_words.len:
    if f < links.len:
      total_links[f] = "`" & total_words[f] & " <" & links[f] & ">`_"

  # Now reverse back from the split words attempting to replace their links.
  var
    final_text = text.replace(" ", "\n")
    pos = final_text.len - 1
    count = 0

  total_words.reverse
  total_links.reverse

  for word in total_words:
    pos = final_text.rfind(word, pos)
    if pos < 0:
      echo final_text
      echo("Failed for word " & word & ", count " & $count)
      assert pos >= 0
    final_text = final_text[0 .. <pos] &
      total_links[count] &
      final_text[pos + word.len .. final_text.high]
    count.inc
  echo final_text


when isMainModule: main()
