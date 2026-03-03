Set of server greeting test fixtures (aka. examples). Each fixture contains lines prefixed with "S: " or "C: " signifying the source of 
the message (and implicitly the target).

One example stands out from the rest - a fixture marked with "; DEFAULT_SERVER_GREETING", this marker indicates the default server greeting
applied to all test cases during the tests setup.

### Default server greeting
```
; DEFAULT_SERVER_GREETING
S: * OK [CAPABILITY XAPPLEPUSHSERVICE IMAP4 IMAP4rev1 SASL-IR AUTH=ATOKEN AUTH=PLAIN AUTH=ATOKEN2 AUTH=XOAUTH2] (2606B15-0579518368c0) p00-iscream-55668b59f7-6f7mg
```