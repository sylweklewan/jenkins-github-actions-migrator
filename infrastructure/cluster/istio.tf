# # ----------------------
# # Install Istio Base + Istiod + Ingress Gateway
# # ----------------------
# resource "helm_release" "istio_base" {
#   name             = "istio-base"
#   repository       = "https://istio-release.storage.googleapis.com/charts"
#   chart            = "base"
#   namespace        = "istio-system"
#   create_namespace = true
#   version = "1.26.2"
# }

# resource "helm_release" "istiod" {
#   name       = "istiod"
#   repository = "https://istio-release.storage.googleapis.com/charts"
#   chart      = "istiod"
#   namespace  = "istio-system"
#   version = "1.26.2"
#   depends_on = [helm_release.istio_base]
# }

# resource "helm_release" "istio_ingress_gateway" {
#   name       = "istio-ingress-gateway"
#   repository = "https://istio-release.storage.googleapis.com/charts"
#   chart      = "gateway"
#   namespace  = "istio-system"
#   version = "1.26.2"
#   depends_on = [helm_release.istiod]

#   set = [{
#     name  = "service.type"
#     value = "NodePort"
#   }, 
#   {
#     name  = "service.ports[0].port"
#     value = "80"
#   },
#   {
#     name  = "service.ports[0].targetPort"
#     value = "8080"
#   },
#   {
#     name  = "service.ports[0].nodePort"
#     value = "30070"
#   }]
# }