FROM quay.io/toolbx-images/archlinux-toolbox:latest

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox or distrobox command" \
      summary="A cloud-native terminal experience" \
      maintainer="ben@benhoman.com"

RUN pacman -Syu --noconfirm && pacman -S --needed base-devel

ARG user=makepkg

RUN useradd --system --create-home $user && \
  echo "$user ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user

USER $user
WORKDIR /home/$user

# Install paru
RUN git clone https://aur.archlinux.org/paru.git && \
  cd paru && \
  makepkg -sri --needed --noconfirm && \
  cd && \
  rm -rf .cache paru

# Install my packages
COPY extra-packages .
RUN cat extra-packages | xargs paru -S --noconfirm --removemake
RUN rm extra-packages

# Become root again and do rooty things
USER root

RUN ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/flatpak && \ 
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/docker && \
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/rpm-ostree
     
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen && \
    echo "LANG=en_US.UTF-8" >> /etc/locale.conf
