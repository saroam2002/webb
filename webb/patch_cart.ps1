$productPath = "products.html"
$productText = Get-Content -Path $productPath -Raw
$oldProduct = "</script>`r`n`r`n`r`n    function getCart() {"
if ($productText.IndexOf($oldProduct) -ge 0) {
    $newProduct = "</script>`r`n`r`n<script>`r`n    const cartKey = 'alhayesCart';`r`n`r`n    function getCart() {"
    $productText = $productText.Replace($oldProduct, $newProduct)
    Set-Content -Path $productPath -Value $productText -Encoding utf8
    Write-Output "products patched"
} else {
    Write-Output "products old not found"
}

$cartPath = "cart.html"
$cartText = Get-Content -Path $cartPath -Raw
$oldCart = "</footer>`r`n`r`n`r`n</body>`r`n</html>"
if ($cartText.IndexOf($oldCart) -ge 0) {
    $newCart = @"
</footer>

<script>
    const cartKey = 'alhayesCart';

    function getCart() {
        return JSON.parse(localStorage.getItem(cartKey) || '[]');
    }

    function saveCart(cart) {
        localStorage.setItem(cartKey, JSON.stringify(cart));
    }

    function formatPrice(price) {
        return price + ' دينار';
    }

    function updateSummary(total) {
        document.getElementById('subtotal').textContent = formatPrice(total);
        document.getElementById('total').textContent = formatPrice(total);
    }

    function renderCart() {
        const cart = getCart();
        const container = document.getElementById('cartItems');
        container.innerHTML = '';

        if (cart.length === 0) {
            container.innerHTML = '<p style="text-align:center; padding: 30px; color: #5B3B00;">السلة فارغة حالياً</p>';
            updateSummary(0);
            return;
        }

        let total = 0;
        cart.forEach((item, index) => {
            const itemTotal = item.price * item.quantity;
            total += itemTotal;

            const cartItem = document.createElement('div');
            cartItem.className = 'cart-item';
            cartItem.innerHTML = `
                <div class="item-image">
                    <img src="${item.image}" alt="${item.title}">
                </div>
                <div class="item-details">
                    <h3>${item.title}</h3>
                    <p class="item-price">${formatPrice(item.price)}</p>
                    <div class="quantity-controls">
                        <button class="qty-btn" onclick="changeQuantity(${index}, -1)">-</button>
                        <span class="quantity">${item.quantity}</span>
                        <button class="qty-btn" onclick="changeQuantity(${index}, 1)">+</button>
                    </div>
                </div>
                <div class="item-total">
                    <p>${formatPrice(itemTotal)}</p>
                    <button class="remove-item" onclick="removeItem(${index})">×</button>
                </div>
            `;
            container.appendChild(cartItem);
        });

        updateSummary(total);
    }

    function changeQuantity(index, delta) {
        const cart = getCart();
        if (!cart[index]) return;
        cart[index].quantity += delta;
        if (cart[index].quantity < 1) {
            cart.splice(index, 1);
        }
        saveCart(cart);
        renderCart();
    }

    function removeItem(index) {
        const cart = getCart();
        cart.splice(index, 1);
        saveCart(cart);
        renderCart();
    }

    document.addEventListener('DOMContentLoaded', renderCart);
</script>

</body>
</html>
"@
    $cartText = $cartText.Replace($oldCart, $newCart)
    Set-Content -Path $cartPath -Value $cartText -Encoding utf8
    Write-Output "cart patched"
} else {
    Write-Output "cart old not found"
}
