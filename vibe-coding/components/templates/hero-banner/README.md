# Hero Banner Component

A flexible hero banner component with optional background image and overlay.

## Usage

```markdown
{{< hero-banner
    title="Welcome to TechBiscuit"
    subtitle="Your guide to modern web development"
    image="/images/hero-bg.jpg"
    height="500px" >}}
[Learn More](/blog/)
{{< /hero-banner >}}
```

## Parameters

- `title` (required): Main heading text
- `subtitle` (optional): Subheading text
- `image` (optional): Background image URL
- `overlay` (optional): Add dark overlay - `true`/`false` - Default: `true`
- `height` (optional): Minimum height - Default: `400px`

Inner content becomes CTA button(s).

## Examples

### With Background Image
```markdown
{{< hero-banner
    title="Start Your Journey"
    subtitle="Learn, build, and grow"
    image="/images/workspace.jpg" >}}
[Get Started](/docs/) | [View Examples](/examples/)
{{< /hero-banner >}}
```

### Gradient Style (No Image)
```markdown
{{< hero-banner
    title="Hello World"
    subtitle="Building the future, one line at a time" >}}
[Read the Blog](/blog/)
{{< /hero-banner >}}
```

### Tall Hero
```markdown
{{< hero-banner
    title="Full Height Experience"
    subtitle="Make a bold statement"
    image="/images/hero.jpg"
    height="100vh" >}}
{{< /hero-banner >}}
```

Created: 2025-12-28
