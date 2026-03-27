---
name: session-search
description: Search past Feynman session transcripts to recover prior work, conversations, and research context. Use when the user references something from a previous session, asks "what did we do before", or when you suspect relevant past context exists.
---

# Session Search

Search prior session transcripts to recover past research work and context.

## Search Methods

### Grep Search

Session transcripts are stored as JSONL files. Search directly:

```bash
grep -ril "scaling laws" ~/.feynman/sessions/
```

### Targeted Content Search

For more specific searches within session files:

```bash
grep -l "your search term" ~/.feynman/sessions/*.jsonl
```

Then read a specific session:

```bash
cat ~/.feynman/sessions/<session-file>.jsonl | head -50
```

## When to Use

- User references something from a previous session
- User asks "what did we do before" or "what did we find about X"
- You suspect relevant past context exists that could inform current work
- Looking for a specific research finding, paper, or decision from earlier work
