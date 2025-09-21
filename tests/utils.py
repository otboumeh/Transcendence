import requests
from typing import Iterable

BAD_GATEWAY_CODES = {502, 503, 504, 521, 522, 523}

def assert_not_gateway_error(resp: requests.Response):
    assert resp.status_code not in BAD_GATEWAY_CODES, (
        f"Gateway error {resp.status_code} for {resp.request.method} {resp.url}"
    )

def any_code(resp: requests.Response, ok: Iterable[int]):
    assert resp.status_code in ok, f"{resp.url} -> {resp.status_code}, esperado {ok}"
