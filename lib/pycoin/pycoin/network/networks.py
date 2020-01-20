
import binascii

MAINNET = dict(
    MAGIC_HEADER=binascii.unhexlify('F9BEB4D9'),
    DNS_BOOTSTRAP=[
        "dnsseed.beenode.org"
    ]
)

TESTNET = dict(
    MAGIC_HEADER=binascii.unhexlify('0B110907'),
    DNS_BOOTSTRAP=[
        "test.dnsseed.beenode.org"
    ]
)
