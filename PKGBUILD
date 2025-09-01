pkgname="penv"
pkgver="0.1.1"
pkgrel=2
pkgdesc="A command-line tool for managing Python virtual environments"
arch=("any")
license=("GPL")
depends=("bash" "expect" "python")
optdepends=("bash-completion: for bash auto-completion support")
url="https://github.com/quintin-lee/penv"
source=(penv.tar.gz)
sha512sums=("SKIP")

package() {
    mkdir -p "${pkgdir}/usr/local/bin/"
    mkdir -p "${pkgdir}/usr/local/penv/"
    mkdir -p "${pkgdir}/etc/systemd/system/"
    mkdir -p "${pkgdir}/usr/share/bash-completion/completions/"
    
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
    
    # Set executable permissions
    chmod +x "${pkgdir}/usr/local/penv/penv"
    chmod +x -R "${pkgdir}/usr/local/penv/scripts/"
    
    # Note: systemd commands should not be run during package building
    # These should be handled by the packaging system
}