from brownie import (
    accounts,
    network,
    config,
    Contract,
    MockV3Aggregator,
    VRFCoordinatorMock,
    LinkToken,
    MockDAI,
    MockWETH,
)
from web3 import Web3

LOCAL_BLOCKCHAIN_ENVIRONMENTS = [
    "hardhat",
    "development",
    "ganache-local",
    "ganache-gui",
    "mainnet-fork",
]
FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork", "mainnet-fork-dev"]
OPENSEA_URL = "https://testnets.opensea.io/assets/{}/{}"

contract_to_mock = {
    "eth_usd_price_feed": MockV3Aggregator,
    "dai_usd_price_feed": MockV3Aggregator,
    "fau_token": MockDAI,
    "weth_token": MockWETH,
    # "vrf_coordinator": VRFCoordinatorMock,
    # "link_token": LinkToken,
}


DECIMALS = 18
INITIAL_PRICE_FEED_VALUE = Web3.toWei(2000, 'ether')
BREED_MAPPING = {0: "PUG", 1: "SHIBA_INU", 2: "ST_BERNARD"}


def get_breed(breed_number):
  return BREED_MAPPING[breed_number]

def get_account(index=None, id=None):
    # accounts[0]
    # accounts.add(key)
    # accounts.load(id)
    if index:
        return accounts[index]
    if id:
        return accounts.load(id)
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
        or network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    ):
        return accounts[0]

    return accounts.add(config["wallets"]["from_key"])


def get_contract(contract_name):
    """This functin will grab the contract addresses from the brownie config
    if defined, it will deploy a mock version of that contract, and `
    return that mock contract.

      Args:
        contract_name(string)
      Returns:
        brownie.network.contract.ProjectContract: The most recently deployed version of this contract.
    """
    contract_type = contract_to_mock[contract_name]
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        if len(contract_type) <= 0:
            deploy_mocks()
        contract = contract_type[-1]
    else:
        contract_address = config["networks"][network.show_active()][contract_name]
        contract = Contract.from_abi(
            contract_type._name, contract_address, contract_type.abi
        )
    return contract


def deploy_mocks(decimals=DECIMALS, initial_value=INITIAL_PRICE_FEED_VALUE):
    account = get_account()

    print("Deploying mock DAI")
    dai_token = MockDAI.deploy({"from": account})
    print(f"Deployed to {dai_token.address}")

    print("Deploying Mock WETH")
    weth_token = MockWETH.deploy({"from": account})
    print(f"Deployed to {weth_token.address}")

    print('Deploying Mock Price Feed...')
    mock_price_feed = MockV3Aggregator.deploy(decimals, initial_value, {"from": account})
    print(f"Deployed to {mock_price_feed}")

    # link_token = LinkToken.deploy({"from": account})
    # VRFCoordinatorMock.deploy(link_token.address, {"from": account})

    print("Deployed!")
