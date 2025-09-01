pkgname="penv"
pkgver="0.1.1"
pkgrel=2
pkgdesc="Manager Python venv in your terminal!"
arch=("any")
license=("GPL")
depends=("expect")

source=(penv.tar.gz)

sha512sums=("SKIP")

package() {
    mkdir -p "${pkgdir}/usr/local/bin/"
    mkdir -p "${pkgdir}/usr/local/penv/"
    mkdir -p "${pkgdir}/etc/systemd/system/"
    cp -r "${srcdir}/penv" "${pkgdir}/usr/local/penv/"
    cp -r "${srcdir}/scripts" "${pkgdir}/usr/local/penv/"
    cp -r "${srcdir}/scripts/penv.service" "${pkgdir}/etc/systemd/system/"
    ln -sf "/usr/local/penv/penv" "${pkgdir}/usr/local/bin/penv"
    chmod +x "${pkgdir}/usr/local/penv/penv"
    chmod +x -R "${pkgdir}/usr/local/penv/scripts/"
    systemctl daemon-reload
    systemctl start penv
    systemctl enable penv
}