---
autoInvoke: false
---
You are going to create an Architecture Decision Record for the following
decision:

> $ARGUMENTS

## Step 1: Gather Context

Examine the existing `docs/decisions/` directory and read any ADRs that may be
relevant to the topic at hand.

## Step 2: Interview

Before you make any changes, you must think about whether you should ask me
clarifying questions, especially to ensure the motivation for the decision is
clear. Think critically about the discussion prior to this decision being made.
Think critically about what to include in considered in the “pros and cons” of
each option — were they actually considered? Only include the most poignant
options considered — sometimes less is more.

## Step 3: Write the ADR

You will add this ADR to the `docs/decisions` directory with the next available
number, in the format `ADR-000-decision-name.md`, where `000` is the next
available number in the directory, and `decision-name` is a short name for the
decision being made. Do not include `architecture` in the decision name. Scan the
directory to ensure you do not choose an existing number. Create the directories
if they do not exist. Use the attached template.

## Step 4: Review

After you have created the ADR, review this project’s documentation to see if
if it will need adjustments. This includes the README.md and CLAUDE.md files.
Consult me about those changes before you make them.

When updating documentation, do not modify existing ADRs. Generally, they are
immutable records. However, it may be appropriate to update them if they are not
yet committed to version control. Let me decide what to do in this scenario.
Think about if this decision means a past decision is superceded and review any
ADRs that could potentially be impacted.

## Attachements

Here is the ADR template to use:

<adr-template-markdown>
---
# These are optional metadata elements. Feel free to remove any of them.
status: '{proposed | rejected | accepted | deprecated | … | superseded by ADR-0123'
date: { YYYY-MM-DD when the decision was last updated }
decision-makers: '@limulus'
---

# {short title, representative of solved problem and found solution}

## Context and Problem Statement

{Describe the context and problem statement, e.g., in free form using two to three sentences or in the form of an illustrative story. You may want to articulate the problem in form of a question and add links to collaboration boards or issue management systems.}

<!-- This is an optional element. Feel free to remove. -->

## Decision Drivers

- {decision driver 1, e.g., a force, facing concern, …}
- {decision driver 2, e.g., a force, facing concern, …}
- … <!-- numbers of drivers can vary -->

## Considered Options

- {title of option 1}
- {title of option 2}
- {title of option 3}
- … <!-- numbers of options can vary -->

## Decision Outcome

Chosen option: "{title of option 1}", because {justification. e.g., only option, which meets k.o. criterion decision driver | which resolves force {force} | … | comes out best (see below)}.

<!-- This is an optional element. Feel free to remove. -->

### Consequences

- Good, because {positive consequence, e.g., improvement of one or more desired qualities, …}
- Bad, because {negative consequence, e.g., compromising one or more desired qualities, …}
- … <!-- numbers of consequences can vary -->

<!-- This is an optional element. Feel free to remove. -->

### Confirmation

{Describe how the implementation of/compliance with the ADR can/will be confirmed. Are the design that was decided for and its implementation in line with the decision made? E.g., a design/code review or a test with a library such as ArchUnit can help validate this. Not that although we classify this element as optional, it is included in many ADRs.}

<!-- This is an optional element. Feel free to remove. -->

## Pros and Cons of the Options

### {title of option 1}

<!-- This is an optional element. Feel free to remove. -->

{example | description | pointer to more information | …}

- Good, because {argument a}
- Good, because {argument b}
<!-- use "neutral" if the given argument weights neither for good nor bad -->
- Neutral, because {argument c}
- Bad, because {argument d}
- … <!-- numbers of pros and cons can vary -->

### {title of other option}

{example | description | pointer to more information | …}

- Good, because {argument a}
- Good, because {argument b}
- Neutral, because {argument c}
- Bad, because {argument d}
- …

<!-- This is an optional element. Feel free to remove. -->

## More Information

{You might want to provide additional evidence/confidence for the decision outcome here and/or document the team agreement on the decision and/or define when/how this decision the decision should be realized and if/when it should be re-visited. Links to other decisions and resources might appear here as well.}
</adr-template-markdown>

