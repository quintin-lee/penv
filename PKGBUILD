pkgname="penv"
pkgver="0.1"
pkgrel=1
pkgdesc="Manager Python venv in your terminal!"
arch=("any")
license=("GPL")
depends=("expect")

source=(penv.tar.gz)

sha512sums=("SKIP")

package() {
    mkdir -p "${pkgdir}/usr/local/bin/"
    mkdir -p "${pkgdir}/usr/local/penv/"
    cp -r "${srcdir}/penv" "${pkgdir}/usr/local/penv/"
    cp -r "${srcdir}/scripts" "${pkgdir}/usr/local/penv/"
    ln -sf "/usr/local/penv/penv" "${pkgdir}/usr/local/bin/penv"
    chmod +x "${pkgdir}/usr/local/penv/penv"
    chmod +x -R "${pkgdir}/usr/local/penv/scripts/"
}

