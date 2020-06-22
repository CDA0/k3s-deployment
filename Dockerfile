ARG K3S_VERSION v1.18.2-k3s1-amd64
FROM rancher/k3s:$K3S_VERSION as base

# https://github.com/rancher/k3s/issues/390
# Because of the above issue, we want to add
# some software into our container, and alpine
# is easier to work with than scratch.
FROM alpine:3.10

# Add our patch to enable Kubelet to act as NFS client
# so our pods can use NFS volumes
RUN apk add --no-cache nfs-utils

# Do the same stuff in the k3s-scratch image's
# final stage.
# https://github.com/rancher/k3s/blob/master/package/Dockerfile
COPY --from=base /tmp /tmp
COPY --from=base /run /run
# COPY --from=base /etc /etc
COPY --from=base /var /var
COPY --from=base /lib /lib
COPY --from=base /bin /bin
RUN mkdir -p /etc && \
    echo 'hosts: files dns' > /etc/nsswitch.conf

RUN chmod 1777 /tmp
VOLUME /var/lib/kubelet
VOLUME /var/lib/rancher/k3s
VOLUME /var/lib/cni
VOLUME /var/log
ENV PATH="$PATH:/bin/aux"

RUN echo "#!/bin/sh" > /entrypoint && \
echo -e '\
rpcbind -f & \n\
/bin/k3s $@' >> /entrypoint && chmod +x /entrypoint

ENTRYPOINT ["/entrypoint"]
CMD ["agent"]