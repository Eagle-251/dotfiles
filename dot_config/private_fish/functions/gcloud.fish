function gcloud
podman run -it --rm --volumes-from gcloud-config gcr.io/google.com/cloudsdktool/google-cloud-cli:alpine gcloud $argv
end
