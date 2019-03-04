<template>
  <section class="container">
    <div>
      <h1 class="title">
        revenue share contract
      </h1>
      <h2 class="subtitle">
        報酬分配を自動化して、お金で揉めなくなることを目指します
      </h2>
      <div>
        あなたのCoinBase {{CoinBase}}
      </div>
      <div>
        アカウント数 {{AccountCount}}
      </div>
      <div>
        あなたのAccount {{Account0}}
      </div>

      <div>
          <button type="button" class="btn btn-primary" @click="member_check">私はメンバー？</button>
        {{IsMember}}
      </div>
    </div>
  </section>
</template>

<script>
import AppLogo from '~/components/AppLogo.vue'
//import web3 from '../helper/web3';
//import contract from '../helper/contract';
import Web3 from 'web3';
import abi from '../helper/abi';

export default {
  data() {
    return {
      Host: "wait..",
      CoinBase: "wait...",
      AccountCount: "0",
      Account0: "wait...",
      IsMember: false,
    }
  },
  beforeMount(){
    //console.log("in beforeMount");
    //ethereum.address = "0x20Edd3b4350c1B5Af4f99DCa29AEf4c5C0473f1E";
    //console.log("ethereum: ", ethereum);

    let web3 = new Web3(ethereum);
    ethereum.enable();

    this.Host = web3.currentProvider.host;
    web3.eth.getCoinbase().then(val => this.CoinBase = val);    // <== ここでweb3使用、CoinBase変数にバインド
    web3.eth.getAccounts().then(val => this.AccountCount = val.length);
    web3.eth.getAccounts().then(val => this.Account0 = val[0]);

    this.web3 = web3;
  },
  methods: {
    member_check(){
      const contract = this.web3.eth.Contract(abi, "0x20Edd3b4350c1B5Af4f99DCa29AEf4c5C0473f1E");

      console.log("contract: ", contract);
      //contract.amIMember.call().then(val => this.IsMember = val);
      let response = contract.methods.amIMember();
      console.log("response: ", response);
      let response2 = contract.methods.amIMember().call();
      console.log("response2: ", response2);
    }
  }
}


</script>

<style>
.container {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  text-align: center;
}

.title {
  font-family: "Quicksand", "Source Sans Pro", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; /* 1 */
  display: block;
  font-weight: 300;
  font-size: 100px;
  color: #35495e;
  letter-spacing: 1px;
}

.subtitle {
  font-weight: 300;
  font-size: 42px;
  color: #526488;
  word-spacing: 5px;
  padding-bottom: 15px;
}

.links {
  padding-top: 15px;
}
</style>

