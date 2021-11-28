<template lang="html">
          <div>
            <p>Your balance: {{ balance }}</p>
            <p>Amount to add:</p>
            <input
              id="amount"
              type="number"
              class="input-username"
              v-model="amount"
            />
            <span v-if="this.insufficientBalance" style="color: red">
              You don't have enough tokens
            </span>
            <span v-if="this.amountNull" style="color: red">
              Check the amount
            </span>
          </div>

          <div>
            <button style="color: green" @click="addAmount">
              Add !
            </button>
               &nbsp;
            <button @click="this.$emit('close')">
              Close
            </button>
          </div>

</template>

<script lang="ts">
import { defineComponent, computed } from 'vue'
import { useStore } from 'vuex'

export default defineComponent({
  name: 'AddBalanceEntreprise',
  props: {
    ownerAddress: String,
  },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const contract = computed(() => store.state.contract)
    return { address, contract }
  },
  data() {
    const insufficientBalance = false
    const amountNull = false
    const balance = 0
    const amount = 0
    return { insufficientBalance, amountNull, balance, amount }
  },
  methods: {
    async updateAccount() {
      const { address, contract } = this
      await contract.methods.user(address).call()
    },
    async addAmount() {
      if (this.amount > this.balance) {
        this.insufficientBalance = true
      } else if (this.amount == 0) {
        this.amountNull = true
      } else {
        this.insufficientBalance = false
        await this.contract.methods.addBalanceEntreprise(this.amount).send()
        location.reload()
        this.$emit('close')
      }
    },
  },
  async mounted() {
    const { address, contract } = this
    const account = await contract.methods.user(address).call()
    this.balance = account.balance
    this.amount = Math.round(this.balance / 10)
  },
})
</script>

<style lang="css">
.input-username {
  background: transparent;
  border: none;
  padding: 12px;
  outline: none;
  width: 100%;
  color: white;
  font-family: inherit;
  font-size: 1.3rem;
}
</style>