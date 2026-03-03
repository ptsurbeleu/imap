### Example (w/ no status updates)
```
C: a002 NOOP
S: a002 OK NOOP completed
```

### Example (w/ status updates):
```
C: a047 NOOP
S: * 22 EXPUNGE
S: * 23 EXISTS
S: * 3 RECENT
S: * 14 FETCH (FLAGS (\Seen \Deleted))
S: a047 OK NOOP completed
```