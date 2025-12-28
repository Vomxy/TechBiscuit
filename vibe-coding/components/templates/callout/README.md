# Callout Component

A versatile callout/alert box component for highlighting important information.

## Usage

Copy `template.html` to `themes/techbiscuits/layouts/shortcodes/callout.html`

Then use in your markdown:

```markdown
{{< callout type="info" title="Did you know?" icon="💡" >}}
This is an info callout with custom icon and title.
{{< /callout >}}

{{< callout type="warning" >}}
This is a warning without a title.
{{< /callout >}}
```

## Parameters

- `type` (optional): `info`, `success`, `warning`, `danger`, `tip` - Default: `info`
- `title` (optional): Callout title/heading
- `icon` (optional): Emoji or text icon - Default varies by type

## Types

| Type      | Color  | Default Icon | Use Case                    |
|-----------|--------|--------------|----------------------------|
| info      | Blue   | ℹ️           | General information        |
| success   | Green  | ✅           | Success messages           |
| warning   | Orange | ⚠️           | Important warnings         |
| danger    | Red    | ❌           | Critical alerts            |
| tip       | Accent | 💡           | Tips and helpful hints     |

## Styling

Add `styles.css` content to your main `style.css` file or create a separate component stylesheet.

## Examples

### Basic Info
```markdown
{{< callout type="info" >}}
Hugo is a fast static site generator.
{{< /callout >}}
```

### Warning with Title
```markdown
{{< callout type="warning" title="Breaking Change" icon="🚨" >}}
This feature will be deprecated in v2.0. Please migrate to the new API.
{{< /callout >}}
```

### Success Message
```markdown
{{< callout type="success" title="Deployment Complete" >}}
Your site has been successfully deployed to GitHub Pages!
{{< /callout >}}
```

## Notes

- Fully responsive
- Works with markdown content inside
- Customizable via CSS variables
- Accessible with proper semantic HTML

Created: 2025-12-28
