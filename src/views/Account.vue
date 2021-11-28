<template lang="html">
  <div class="account" v-if="account">
  <spacer :size="24" />
    <card
      title="Account information"
      :gradient="true"
    >
      <div class="explanations">
        <p><b>Username: </b>{{ account.username }}</p>
        <p><b>Balance: </b>{{ account.balance }} tokens</p>
        <p>
        <a href="#" style="color: white" @click="addTokens">
          Add balance (for tests only)
        </a>
        </p>
      </div>
    </card>
    <spacer :size="24" />
    <card
      title="Entreprise"
      v-if="entreprise"
    >
      <div class="explanations" v-if="entreprise">
        <p><b>Name: </b>{{ entreprise.name }}</p>
        <p><b>Owner: </b>{{ this.entrepriseOwner.username }}</p>
        <div>
          <b>Members: </b>
          <p
            v-for="member in entrepriseMembers"
            v-bind:key="member"
            style="padding-left: 10px"
          >
            {{ member }}
          </p>
        </div>
        <p><b>Balance: </b>{{ entreprise.balance }} tokens</p>
        <p>
        <a href="#" style="color: white" @click="addBalance = !addBalance">
          Add balance
          </a>
        </p>
      <add-balance-entreprise
        v-if="addBalance"
        @close="addBalance = false; updateEntrepriseBalance"
      />
      </div>
    </card>
    <spacer :size="24" />
    <card
      title="Projects"
      :subtitle="`You have ${projects.length} projects`"
      v-if="projects"
    >
      <div v-for="project in projects" v-bind:key="project.name">
        <about-project :project="project"></about-project>
      </div>
    </card>
    <spacer :size="24" />
    <div class="signedUp">
      <card
        title="Create an entreprise"
        :blue="true"
        v-if="!entreprise"
      >
        <router-link class="card-body" to="/signup">
          Click here
        </router-link>
      </card>
      <card
        title="Create a project"
        :blue="true"
      >
        <router-link class="card-body" to="/create-project">
          Click here
        </router-link>
      </card>
    </div>
  </div>
  <div class="home" v-else>
    <form @submit.prevent="signUp">
      <card
        title="Enter your username here"
        subtitle="Type directly in the input and hit enter. All spaces will be converted to _"
      >
        <input
          type="text"
          class="input-username"
          v-model="username"
          placeholder="Type your username here"
        />
      </card>
    </form>
  </div>
</template>

<script lang="ts">
import { defineComponent, computed } from 'vue'
import { useStore } from 'vuex'
import Card from '@/components/Card.vue'
import Spacer from '@/components/Spacer.vue'
import AboutProject from '@/components/AboutProject.vue'
import AddBalanceEntreprise from '@/components/AddBalanceEntreprise.vue'

export default defineComponent({
  name: 'Account',
  components: { AboutProject, Spacer, Card, AddBalanceEntreprise },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const balance = computed(() => store.state.account.balance)
    const contract = computed(() => store.state.contract)
    return { address, contract, balance }
  },
  data() {
    const account = null
    const username = ''
    const entrepriseOwner = { username: '', balance: 0 }
    const entreprise = null
    const entrepriseMembers: any[] = []
    const projects: any[] = []
    const addBalance = false
    
    return {
      account,
      username,
      entrepriseOwner,
      entreprise,
      entrepriseMembers,
      projects,
      addBalance
    }
  },
  methods: {
    async updateAccount()  {
      const { address, contract } = this
      this.account = await contract.methods.user(address).call()
    },
    async signUp() {
      const { contract, username } = this
      const name = username.trim().replace(/ /g, '_')
      await contract.methods.signUp(name).send()
      await this.updateAccount()
      this.username = ''
    },
    async addTokens() {
      const { contract } = this
      await contract.methods.addBalance(100).send()
      await this.updateAccount()
    },
  },
  async mounted() {
    const { address, contract } = this
    const account = await contract.methods.user(address).call()
    if (account.registered) this.account = account
    const entreprise = await contract.methods.entreprise(address).call()
    if (entreprise.name) {
      this.entreprise = entreprise
      this.entrepriseOwner = await contract.methods
        .user(entreprise.owner)
        .call()
      for (const address of entreprise.members) {
        const member = await contract.methods.user(address).call()
        this.entrepriseMembers.push(member.username)
      }
    }
    const projects = await contract.methods.userProjects(address).call()
    if (projects) {
      for (const project of projects) {
        let owner = project.belongsToUser
          ? await contract.methods.user(project.owner).call()
          : contract.methods.entreprise(project.owner).call()
        let contributors = []
        for (const address of project.contributors) {
          const contributor = await contract.methods.user(address).call()
          contributors.push(contributor.username)
        }
        this.projects.push({
          id: project.id,
          name: project.name,
          owner: {
            name: owner.name || null,
            username: owner.username || null,
            balance: owner.balance,
          },
          ownerAddress: project.owner,
          belongsToUser: project.belongsToUser,
          balance: project.balance,
          contributors: contributors,
        })
      }
    }
  },
})
</script>

<style lang="css" scoped>
.home {
  padding: 24px;
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  max-width: 500px;
  margin: auto;
}

.account {
  margin: auto 24px auto 24px;
}

.signedUp {
  display: grid;
  align-items: center;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  grid-gap: 24px;
}

.card-body {
  padding: 12px;
  display: block;
  font-family: inherit;
  font-size: 1.2rem;
  font-weight: inherit;
  text-align: center;
  color: inherit;
  text-decoration: none;
  font-variant: small-caps;
}

.explanations {
  padding: 12px;
}

.button-link {
  display: inline;
  appearance: none;
  border: none;
  background: none;
  color: inherit;
  text-decoration: underline;
  font-family: inherit;
  font-size: inherit;
  font-weight: inherit;
  padding: 0;
  margin: 0;
  cursor: pointer;
}

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