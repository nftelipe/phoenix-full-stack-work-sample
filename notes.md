## App details page: new features
* **Deployment status** section showing details from the last deploy.
* **Instances** table listing all running instances.
* **Auto refresh**: The page calls the graphql API every 5 seconds and re-renders the page if
  there are changes.
* `flyctl status` returns three sections: App, DeploymentStatus and Instances. The **App** section
  wasn't inserted into this page since all the information from it is already included inside
  the `<header>` tag.

## What can be improved
* Instances table need to be responsive to fit in mobile viewport.
* Instances table can include a checkbox to enable listing all (same as `flyctl status --all`).
* Page's auto refresh can be replaced by a graphql subscription operation. It would require some work
  on the graphql server first.
* In order to transport less data over the wire, the `@app` assign could be splitted. This way,
  whenever a deploy occurs, it only transports the allocations list over the websocket.
* Datetimes could be converted from `2021-09-12T19:43:36Z` format to `6 hours ago` using `Timex.from_now/1`.
* User image on Timeline section could have a fallback image source in case the gravatar is not found.
* Create css classes usign Tailwind's `@apply` in order to reduce repeating classes in the `.heex` code.

## Measuring this feature success
With this patch we are aggregating value to the app details page, introducing no new call to action and
no new interactive feature. What we can expect from this is that unique users start vieweing more this
page and spending more time in it.
