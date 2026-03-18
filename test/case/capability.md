6.1.1.  CAPABILITY Command

   Arguments:  none

   Responses:  REQUIRED untagged response: CAPABILITY

   Result:     OK - capability completed
               BAD - command unknown or arguments invalid

      The CAPABILITY command requests a listing of capabilities that the
      server supports.  The server MUST send a single untagged
      CAPABILITY response with "IMAP4rev1" as one of the listed
      capabilities before the (tagged) OK response.

      A capability name which begins with "AUTH=" indicates that the
      server supports that particular authentication mechanism.  All
      such names are, by definition, part of this specification.  For
      example, the authorization capability for an experimental
      "blurdybloop" authenticator would be "AUTH=XBLURDYBLOOP" and not
      "XAUTH=BLURDYBLOOP" or "XAUTH=XBLURDYBLOOP".

      Other capability names refer to extensions, revisions, or
      amendments to this specification.  See the documentation of the
      CAPABILITY response for additional information.  No capabilities,
      beyond the base IMAP4rev1 set defined in this specification, are
      enabled without explicit client action to invoke the capability.

      Client and server implementations MUST implement the STARTTLS,
      LOGINDISABLED, and AUTH=PLAIN (described in [IMAP-TLS])
      capabilities.  See the Security Considerations section for
      important information.

      See the section entitled "Client Commands -
      Experimental/Expansion" for information about the form of site or
      implementation-specific capabilities.

### Example:
```
C: a0001 CAPABILITY
S: * CAPABILITY IMAP4rev1 STARTTLS AUTH=GSSAPI LOGINDISABLED
S: a0001 OK CAPABILITY completed
```

### Example
```
C: a00002 STARTTLS
S: a00002 OK STARTLS completed
<TLS negotiation, further commands are under [TLS] layer>
C: a00003 CAPABILITY
S: * CAPABILITY IMAP4rev1 AUTH=GSSAPI AUTH=PLAIN
S: a00003 OK CAPABILITY completed
```

### Example (iCloud)
```
C: c00003 CAPABILITY
S: * CAPABILITY XAPPLEPUSHSERVICE IMAP4 IMAP4rev1 SASL-IR AUTH=ATOKEN AUTH=PLAIN AUTH=ATOKEN2 AUTH=XOAUTH2
S: c00003 OK Completed
```

### Example (Gmail)
```
C: a005 CAPABILITY
S: * CAPABILITY IMAP4rev1 UNSELECT IDLE NAMESPACE QUOTA ID XLIST CHILDREN X-GM-EXT-1 XYZZY SASL-IR AUTH=XOAUTH2 AUTH=PLAIN AUTH=PLAIN-CLIENTTOKEN AUTH=OAUTHBEARER
S: a005 OK Thats all she wrote! d2e1a72fcca58-82a1004806amb45731469b3a
```