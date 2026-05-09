\# <span style="color:#4FC3F7;">Tor Snowflake Standalone Proxy — Q\&A</span>



> A beginner-friendly explanation of how the project works, what the logs mean, and common technical questions.



\---



\# <span style="color:#81C784;">General Questions</span>



\## <span style="color:#FFD54F;">What is this project?</span>



This project runs a standalone Tor Snowflake proxy using the official Snowflake implementation from the Tor Project.



It helps censored users connect to the Tor network by temporarily relaying encrypted traffic through WebRTC.



Unlike the browser extension, this version runs as a standalone process from the command line.



\---



\## <span style="color:#FFD54F;">What is Tor Snowflake?</span>



Snowflake is a censorship circumvention system created by the Tor Project.



It allows volunteers to temporarily proxy internet traffic for users in censored regions.



Snowflake uses:



\- WebRTC

\- temporary peer-to-peer connections

\- distributed volunteer proxies



to help users access the Tor network.



\---



\## <span style="color:#FFD54F;">Is this a Tor exit node?</span>



No.



This project is \*\*NOT\*\*:



\- a Tor exit node

\- a traditional Tor relay

\- a VPN server



It only forwards encrypted traffic into the Tor network.



Websites visited by users do \*\*NOT\*\* normally see your IP address.



\---



\# <span style="color:#81C784;">Networking \& NAT</span>



\## <span style="color:#FFD54F;">What is NAT?</span>



\*\*NAT = Network Address Translation\*\*



Your router translates private local IP addresses into a public internet-facing IP address.



Example:



```txt

Local Device:

192.168.1.10



Public IP:

190.x.x.x

```



\---



\## <span style="color:#FFD54F;">What does "restricted NAT" mean?</span>



A restricted NAT means:



\- peer-to-peer traffic is partially limited

\- UDP hole punching may fail sometimes

\- some WebRTC sessions may timeout



However, many restricted NATs still work with Snowflake.



\---



\# <span style="color:#81C784;">WebRTC \& Connectivity</span>



\## <span style="color:#FFD54F;">What is WebRTC?</span>



\*\*WebRTC = Web Real-Time Communication\*\*



A browser technology for:



\- peer-to-peer communication

\- voice/video calls

\- encrypted real-time transport



Snowflake uses \*\*WebRTC DataChannels\*\* to relay Tor traffic.



\---



\## <span style="color:#FFD54F;">What are DataChannels?</span>



DataChannels are encrypted peer-to-peer data streams.



Think of them like:



```txt

Encrypted tunnel between client and proxy

```



Snowflake uses them instead of audio/video streams.



\---



\## <span style="color:#FFD54F;">What are ICE candidates?</span>



ICE stands for:



> Interactive Connectivity Establishment



ICE candidates are possible network paths WebRTC tries during connection setup.



Common types:



| Type | Meaning |

|---|---|

| `host` | Local/private IP |

| `srflx` | Public NAT-discovered IP |



\---



\## <span style="color:#FFD54F;">What is SDP?</span>



SDP stands for:



> Session Description Protocol



It contains:



\- connection metadata

\- UDP ports

\- encryption fingerprints

\- ICE candidates



Example from logs:



```txt

a=candidate:2398380560 1 udp ...

```



\---



\# <span style="color:#81C784;">Privacy \& Security</span>



\## <span style="color:#FFD54F;">Is my real IP address exposed?</span>



Partially.



The censored user connecting through WebRTC can see your public IP address.



However:



\- destination websites usually do NOT see your IP

\- Tor exit nodes handle final outbound traffic



\---



\## <span style="color:#FFD54F;">Can my ISP see what users browse?</span>



No.



Your ISP may see:



\- encrypted WebRTC traffic

\- connections to Snowflake infrastructure



But NOT:



\- websites visited

\- Tor payload contents

\- browsing activity



\---



\## <span style="color:#FFD54F;">Is the traffic encrypted?</span>



Yes.



Snowflake uses:



\- DTLS

\- WebRTC encryption

\- Tor encryption layers



Traffic is encrypted end-to-end.



\---



\# <span style="color:#81C784;">Logs \& Troubleshooting</span>



\## <span style="color:#FFD54F;">What does "Connection successful" mean?</span>



It means:



✅ WebRTC handshake completed  

✅ DataChannel opened  

✅ Traffic relay active



Example:



```txt

Connection successful

Data Channel open

```



\---



\## <span style="color:#FFD54F;">Why do some connections timeout?</span>



This is normal.



Possible causes:



\- restrictive NAT

\- client disconnected

\- browser closed

\- censorship interference

\- unstable mobile network



Snowflake is designed for temporary short-lived sessions.



\---



\## <span style="color:#FFD54F;">What does this error mean?</span>



```txt

Error loading geoip db for country based metrics

```



Usually harmless on Windows.



The proxy is trying to load Linux Tor GeoIP files that may not exist.



Functionality is normally unaffected.



\---



\# <span style="color:#81C784;">How Snowflake Works</span>



```txt

Censored User

&#x20;     ↓

Your Snowflake Proxy

&#x20;     ↓

Snowflake Relay

&#x20;     ↓

Tor Network

&#x20;     ↓

Tor Exit Node

&#x20;     ↓

Website

```



The website normally sees the \*\*Tor exit node IP\*\*, not yours.



\---



\# <span style="color:#81C784;">Project Goal</span>



This project exists for:



\- learning

\- experimentation

\- supporting internet freedom

\- understanding WebRTC

\- exploring Tor Snowflake infrastructure





