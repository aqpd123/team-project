from app.domain.celebrity.services.celebrity_service import CelebrityService

service = CelebrityService()
celebs = service.list_celebrities()
print(f'Total celebrities: {len(celebs)}')
for c in celebs[:10]:
    print(f'{c["id"]}: {c["name"]} - element: {c.get("element", "N/A")}, character_type: {c.get("character_type", "N/A")}')

