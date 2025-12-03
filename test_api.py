from app.main import create_app

app = create_app()
with app.test_client() as client:
    r = client.get('/celebrities')
    print('Status:', r.status_code)
    data = r.get_json()
    print('Count:', data.get('count', 0))
    items = data.get('items', [])
    print(f'Total items: {len(items)}')
    for item in items[:5]:
        print(f"  {item.get('id')}: {item.get('name')} - element: {item.get('element', 'N/A')}")

