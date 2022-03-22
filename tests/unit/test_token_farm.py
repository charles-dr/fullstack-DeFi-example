from brownie import network
import pytest
from scripts.helpful_scripts import (
    get_account,
    get_contract,
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
)
from scripts.deploy import deploy_token_farm_and_dapp_token


def test_set_price_feed_contract():
    # Arrange
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("Only for local testing!")

    account = get_account()
    non_owner = get_account(index=1)
    token_farm, dapp_token = deploy_token_farm_and_dapp_token()

    # Act
    price_feed_address = get_contract("eth_usd_price_feed").address
    token_farm.setPriceFeedContract(
        dapp_token.address,
        price_feed_address,
        {"from": account},
    )

    # Assert
    assert (
        token_farm.tokenPriceFeedMapping(dapp_token.address)
        == price_feed_address
    )
    
