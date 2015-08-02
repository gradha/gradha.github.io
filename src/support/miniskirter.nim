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

-_u5XQ0OFbc
-i_2DIGBmO4
-uZj3EVuSiM
0h9h__Mqaag
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
5ohwNCL4FSk
6JhZhMYx780
6Zl5M-7tORI
6_HHut7u29w
6hqSmVRXwTE
7LqV-Q_jWf4
85kgIuq3HY4
8NFXElCZY4I
91FleKcgKbE
9g2YPmzDfkI
AMnCUFeGYSY
A_MCEHd6now
Ac7SN63L6po
B99pOzAfFy4
BygwsVYUbO8
CTAAn5vbVPs
D0TkSCpBSc0
D3taDrdlUlU
DBNAWLlPxCY
DO8SJ2uxV4s
Dgwth72XZCQ
Dq99wBcCbzM
EDxOSsiaEYU
Ez_5wP-7i3g
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
KnW0lLziN5o
KvfmywBHNaI
L-I0o5bB0D0
LRnblsA54ZI
MQ2sOfXhr3I
MV6kO9FISdY
MX4JXqOCcTs
MrTrlRLAH-s
Mwf6jxUBU0Q
NTEOMaXxc3w
NWD3C0ax-ZY
NeAgohY9hqM
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
S93M6XsGLtk
SQq8lPtK65g

BROWqjuTM0g

SnmUALfrJMw
TUrxPOF9kZs
UzkAGgBDHTM
V2AJZb0arkk
VDJRMjtzvlg
VP-mRUMELWo
V_lvh4HuOKA
Vdd-z87h0Ek
WHTqrECQZyw
WyN7uzv55Qs
X6wFClkX9gs
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
b6N05SU2UxA
bQ3XlIQyPEI
biCkA4q2_FE
chkdylyKgJE
d-omo9nuYss
dC2iOh831Jg
dCDij8E7fwo
dLTSeAiPK34
d_SO284MFfs
eK3KJ7AlxNs
ePuj3g2giUY
f0uY0zFG0y8
fLZG31_AKsQ
fZ8ebCBb8z4
g9aVn2qCLYg
gyNwlClqFP8
haOvfeui2K0
i0jDsG94m90
iAertuXKvnc
iG7sb6PlbeQ
jD4hmNisjM4
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
oc2uE_Oobgw
ojvES51dOUY
onLZnNNymTU
ooJiMFG-Uuo
otJ8jzIBtMM
ozDnGDxh7ZA
pW7NSL9STp4
"""

  extra = """

qIq9V62h7BI
qeOycPTKbl0
qgen0Hv4rBk
r-4_j1V6frE
r4jFOB0cu6s
rQSK66behAQ
s1StWjh0oFo
sQdoijEyc3g
sbG87-GbQWM
stBjpAXjRpY
t4b2Zb67_Ro
tQZlwr1JQ1Q
tZYJXI93RCw
thabOb8WX34
uwhZgR2Wuew
v7cpVcnrPu4
wyIC3Z0_9J8
x7cMdxp49XQ
x9O26UkN9AA
xpbs6SRQsTI
xqmjmR-vRP0
xryLWlBfXa0
yku6QKz6Drc
zWi9Vk77bkY
zp5CwgMSOMU
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
