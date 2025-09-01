pkgname="penv"
pkgver="0.1.1"
pkgrel=2
pkgdesc="A command-line tool for managing Python virtual environments"
arch=("any")
license=("GPL")
depends=("bash" "expect" "python")
optdepends=("bash-completion: for bash auto-completion support"
            "zsh: for zsh auto-completion support")
url="https://github.com/quintin-lee/penv"
source=(penv.tar.gz)
sha512sums=("SKIP")

package() {
    mkdir -p "${pkgdir}/usr/local/bin/"
    mkdir -p "${pkgdir}/usr/local/penv/"
    mkdir -p "${pkgdir}/etc/systemd/system/"
    mkdir -p "${pkgdir}/usr/share/bash-completion/completions/"
    mkdir -p "${pkgdir}/usr/share/zsh/site-functions/"
    
    # Copy main executable
    cp -r "${srcdir}/penv" "${pkgdir}/usr/local/penv/"
    
    # Copy scripts
    cp -r "${srcdir}/scripts" "${pkgdir}/usr/local/penv/"
    
    # Copy systemd service file
    cp -r "${srcdir}/scripts/penv.service" "${pkgdir}/etc/systemd/system/"
    
    # Create symlink for main executable
    ln -sf "/usr/local/penv/penv" "${pkgdir}/usr/local/bin/penv"
    
    # Install bash completion
    install -Dm644 "${srcdir}/scripts/penv-completion.bash" \
        "${pkgdir}/usr/share/bash-completion/completions/penv"
        
    # Install zsh completion (using the same completion file)
    install -Dm644 "${srcdir}/scripts/penv-completion.bash" \
        "${pkgdir}/usr/share/zsh/site-functions/_penv"
    
    # Set executable permissions
    chmod +x "${pkgdir}/usr/local/penv/penv"
    chmod +x -R "${pkgdir}/usr/local/penv/scripts/"
}

# Function to update shell completion
_update_completion() {
    # For bash users
    if [[ -f /usr/share/bash-completion/bash_completion ]]; then
        source /usr/share/bash-completion/bash_completion 2>/dev/null || true
    fi
    
    # For zsh users
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
        # Refresh command hash
        hash -r 2>/dev/null || true
    fi
}

post_install() {
    # Reload systemd daemon to recognize new service
    systemctl daemon-reload
    
    # Enable the service
    systemctl enable penv.service --now
    
    # Update completion for both bash and zsh
    _update_completion
}

post_upgrade() {
    # Reload systemd daemon to recognize any changes to the service
    systemctl daemon-reload
    
    # Restart the service if it was already enabled
    if systemctl is-enabled --quiet penv.service; then
        systemctl restart penv.service
    fi
    
    # Update completion for both bash and zsh
    _update_completion
}

pre_remove() {
    # Stop and disable the service before removing
    if systemctl is-active --quiet penv.service; then
        systemctl stop penv.service
    fi
    
    if systemctl is-enabled --quiet penv.service; then
        systemctl disable penv.service
    fi
}

post_remove() {
    # Reload systemd daemon to forget about the service
    systemctl daemon-reload
    
    # Reset failed units if any
    systemctl reset-failed
}