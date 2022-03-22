import React from 'react';
import {
  Mainnet,
  DAppProvider,
  useEtherBalance,
  useEthers,
  Config,
  ChainId,
} from '@usedapp/core'
import { Header } from "./components/Header";

const config: Config = {
  supportedChains: [ChainId.Kovan, ChainId.Rinkeby, 1337]
}

function App() {
  return (
    <DAppProvider config={config}>
      <Header />
      <div className="App">
        <h3>Hi</h3>
      </div>
    </DAppProvider>
  );
}

export default App;
