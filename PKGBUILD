# Maintainer: marietesiu
pkgname=sendall
pkgver=1.0.0
pkgrel=1
pkgdesc="Send pop-up alerts to any device on your local network — no receiver install needed"
arch=('any')
url="https://github.com/marietesiu/sendall"
license=('MIT')
depends=('python' 'openssh')
optdepends=('libnotify: for notify-send when receiving on Linux')
source=("git+https://github.com/marietesiu/sendall.git")
sha256sums=('SKIP')

package() {
    install -Dm755 "$srcdir/sendall/sendall" "$pkgdir/usr/bin/sendall"
    install -Dm644 "$srcdir/sendall/README.md" \
        "$pkgdir/usr/share/doc/$pkgname/README.md"
    install -Dm644 "$srcdir/sendall/LICENSE" \
        "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
