# linkerd-sp-swagger-sync

Applying Linkerd ServiceProfiles generated from Swagger automatically

### Goal

Linkerd allows to create ServiceProfiles from a Swagger file. This is great when you can generate it locally, or include it somehow in your deployments (Helm, Flux, etc...)

In my case, I want to reconfigure the ServiceProfile of my backends each time I deploy it in Kubernetes, without wondering if my routes have been updated this time or not. Obviously, several version live at the same time in different clusters, I just don't want to track that.

This docker image aims at getting a Swagger documentation online, process it with linkerd commands to generate the ServiceProfile and apply it in cluster.

In my case, I'll run it as a Helm post-upgrade hook.

### Non Goals

This fulfills a very specific use-case and yours may be different. If your contributions are welcomed, please note that this is a side project that I'll maintain on my free time on a best effort basis. 

Of course, feel also free to fork the project: it's under the [MIT license](LICENSE).

### How to run it ?

Work In Progress
