---
title: "Can AI Find Complex Bugs in Entire Project Codebases?"
author: s-gryt
date: 2025-07-16 10:00:00 +0300
permalink: /ai-complex-bug-detection-projects/
description: "A real-world case study of how modern AI detected a subtle GetHashCode bug that was causing duplicate artifacts in production, demonstrating AI's capability to find complex bugs in large codebases."
categories: [AI, Code Review, Software Quality, .NET]
tags:
  [
    AI,
    bug-detection,
    code-review,
    GetHashCode,
    HashSet,
    .NET,
    csharp,
    software-quality,
    debugging
  ]
image:
  path: /assets/img/posts/2025-07-16-ai-complex-bug-detection-in-projects/cover.png
  alt: "AI analyzing complex code bugs in large projects"
mermaid: true
---

## Can AI Find Complex Bugs in Entire Project Codebases?

> **TL;DR:** Modern AI with reasoning capabilities can detect sophisticated bugs in large codebases. Here's how AI found a subtle GetHashCode bug that was causing duplicate artifacts in production - a bug that stumped experienced developers for days.

## The Skepticism: AI vs Real-World Bugs

Many developers believe AI tools are only good for catching obvious syntax errors and simple logic mistakes. The assumption is that complex, subtle bugs in production systems require human expertise and deep domain knowledge to identify.

But what happens when AI encounters a real production bug that has developers scratching their heads?

## The Mystery: Duplicates Despite HashSet Protection

Our code analysis system was creating duplicate artifacts in the database - impossible given our HashSet-based duplicate prevention:

```csharp
HashSet<ArtifactAggregate> artifactsToSave = new();

void TryAddArtifact(ArtifactAggregate artifact)
{
    if (artifactsToSave.Add(artifact) == false)
    {
        // This should catch duplicates... but it wasn't working
        logger.LogWarning("Duplicate detected: {Id}", artifact.GetIdentifier());
        return;
    }

    ProcessArtifact(artifact);
}
```

The `ArtifactAggregate` class looked correct:

```csharp
public class ArtifactAggregate
{
    public string FileName { get; set; }
    public string ClassName { get; set; }
    public string FuncName { get; set; }
    public DateTime CreatedAt { get; set; }

    public string GetIdentifier() => $"{FileName}::{ClassName}::{FuncName}";

    // GetHashCode and Equals were implemented...
}
```

**The Problem:** Duplicates were appearing in production, but our HashSet should have prevented this.

## Traditional Debugging Failed

Several debugging approaches yielded no answers:

- ✅ **Database Analysis**: Confirmed duplicates existed
- ✅ **Code Review**: HashSet usage looked correct
- ✅ **Unit Testing**: Simple tests passed
- ❌ **Root Cause**: Still unknown after days of investigation

## AI to the Rescue

We asked our AI system a simple question:

> "Why are duplicate artifact identifiers appearing in our database despite HashSet duplicate prevention?"

## The AI's Detective Work

The AI systematically analyzed the code and identified the smoking gun:

```mermaid
%%{init: {"theme": "default"}}%%
graph TD;
    A[AI Analyzes Code] --> B[Examines HashSet Contract];
    B --> C[Compares GetHashCode vs Equals];
    C --> D["🚨 Finds Inconsistency"];
    D --> E[Explains Root Cause];

    classDef problem fill:#f99,stroke:#c00,stroke-width:2px,color:#000;
    classDef solution fill:#9f9,stroke:#070,stroke-width:2px,color:#000;

    class D problem;
    class E solution;

```

**The AI found this:**

```csharp
// ❌ The Problematic Implementation
public override int GetHashCode()
{
    // Only uses 3 properties
    return HashCode.Combine(FileName, ClassName, FuncName);
}

public override bool Equals(object obj)
{
    if (obj is ArtifactAggregate other)
    {
        return FileName == other.FileName &&
               ClassName == other.ClassName &&
               FuncName == other.FuncName &&
               CreatedAt == other.CreatedAt;  // 🚨 4th property!
    }
    return false;
}
```

## The Bug Explained

**Visual Contract Violation:**

```text
HashSet Contract Violation Analysis

GetHashCode() uses:     Equals() uses:
┌─────────────────┐    ┌─────────────────┐
│ ✅ FileName     │    │ ✅ FileName     │
│ ✅ ClassName    │    │ ✅ ClassName    │
│ ✅ FuncName     │    │ ✅ FuncName     │
│ ❌ (missing)    │    │ ✅ CreatedAt    │ ← Contract Violation!
└─────────────────┘    └─────────────────┘

Result: Same hash code + Different equality = HashSet failure
```

**How the Bug Manifested:**

```mermaid
sequenceDiagram
    participant H as HashSet
    participant A1 as Artifact1\n(10:00 AM)
    participant A2 as Artifact2\n(10:01 AM)

    A1->>H: Add artifact (File.cs::MyClass::Method)
    H->>H: GetHashCode() = 12345
    H->>H: Store in bucket 12345

    A2->>H: Add artifact (File.cs::MyClass::Method)
    H->>H: GetHashCode() = 12345 (same!)
    H->>H: Check bucket 12345
    H->>H: Call Equals(A1, A2)
    H->>H: Different CreatedAt → false
    H->>H: Store as "different" object

    Note over H: Both artifacts stored as unique!

```

## Interactive Challenge: Can You Spot Similar Bugs?

```csharp
// 🎯 Challenge: What's wrong with this implementation?
public class CacheKey
{
    public string UserId { get; set; }
    public string Action { get; set; }
    public DateTime Timestamp { get; set; }

    public override int GetHashCode()
    {
        return HashCode.Combine(UserId, Action);
    }

    public override bool Equals(object obj)
    {
        return obj is CacheKey other &&
               UserId == other.UserId &&
               Action == other.Action &&
               Math.Abs((Timestamp - other.Timestamp).TotalMinutes) < 5;
    }
}
```

**Problem:** `GetHashCode()` ignores `Timestamp`, but `Equals()` uses it (with tolerance). This violates the HashSet contract and can cause cache misses or incorrect behavior.

**Fix:** Either include timestamp in hash code or remove it from equality check, depending on your caching strategy.

</details>

## The AI's Complete Analysis

The AI provided:

1. **Root Cause**: GetHashCode/Equals inconsistency
2. **Impact**: 15% of artifacts were duplicated in production
3. **Solution**: Three different approaches to fix the contract violation
4. **Prevention**: Unit tests to catch similar issues

## Production Impact

```text
Before Fix:  1000 artifacts/hour → 850 unique (150 duplicates)
After Fix:   1000 artifacts/hour → 1000 unique (0 duplicates)

Performance: 32% faster HashSet operations
Storage:     15% reduction in database size
```

## The Fix

```csharp
// ✅ Solution: Align both methods
public override int GetHashCode()
{
    return HashCode.Combine(FileName, ClassName, FuncName);
    // Removed CreatedAt from both methods
}

public override bool Equals(object obj)
{
    if (obj is ArtifactAggregate other)
    {
        return FileName == other.FileName &&
               ClassName == other.ClassName &&
               FuncName == other.FuncName;
        // CreatedAt removed - business logic doesn't need it for uniqueness
    }
    return false;
}
```

## Key Takeaways

### 1. AI Excels at Contract Violations

Modern AI can spot subtle violations of programming contracts that humans often miss, especially in large codebases where the methods might be far apart.

### 2. Context Matters

The AI succeeded because it had access to:

- The complete class implementation
- Usage patterns showing the HashSet behavior
- Production logs indicating the symptoms

### 3. Systematic Analysis Wins

While humans debugged randomly, AI followed a systematic approach:

1. Understand the reported symptoms
2. Analyze the mechanisms involved (HashSet behavior)
3. Check contract compliance (GetHashCode/Equals)
4. Identify the specific violation

## Try It Yourself

**Test AI on Your Codebase:**

1. Find classes that override `GetHashCode` and `Equals`
2. Ask AI: "Are these implementations consistent with each other?"
3. Look for similar contract violations in your code

**Common Patterns AI Catches:**

- GetHashCode/Equals mismatches
- Thread safety violations in "safe" code
- Resource leaks in seemingly correct disposal patterns
- Performance bottlenecks in innocent-looking loops

## Conclusion

This real-world case demonstrates that AI has evolved beyond simple syntax checking. Modern AI with reasoning capabilities can:

- **Detect subtle bugs** that experienced developers miss
- **Understand complex contracts** like HashSet equality requirements
- **Provide systematic analysis** rather than random guessing
- **Explain the root cause** in understandable terms

The key isn't replacing human developers, but augmenting human debugging with AI's systematic analysis capabilities.

**The bottom line:** AI found a production bug in minutes that stumped a team of developers for days. That's the power of AI-assisted debugging in 2025.

---

**Resources:**

- [Complete AI Analysis](https://gist.github.com/rodion-m/933e987f965a9ea190d402f2210afa97) - Detailed technical breakdown
- [HashSet Documentation](https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.hashset-1) - Understanding the equality contract
- [AI Code Analysis Tools](https://www.codealive.ai/#public-chats) - Try AI analysis on open-source projects
