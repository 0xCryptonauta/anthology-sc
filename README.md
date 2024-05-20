# **Anthology**

## **Table of Contents**

1. [**WTF is this**](#wtf-is-this)
2. [**Versioning**](#versioning)
   - [v0: Data structure - Memoir](#v0-data-structure-memoir)
   - [v1: Memoir array - Anthology](#v1)
   - [v2: Anthology array - Anthology Tree ](#v2)
   - [v3](#v3)
3. [**Repository cloning**](#repository-cloning)

## **WTF is this**

This contract(s) aim to serve as memory (memoirs) of digital URIs or "notes" made from a basic data structure called memoir.

There are 3 version of this smart contract:

## **_Versioning_**

### v0: Data structure - Memoir

```
struct Memoir {
   uint8 id;            // 8 or 16 bits
   uint timestamp;      // UNIX time
   address sender;
   string title;
   string content;
   bool state;          // can a bool variable be uselful?
}
```

### v1: Memoir array - Anthology

This contract handles the state of an array (Memoirs) of a data structure known as memoir

Lets the deployer of this contract, known as owner, add and delete pieces of data (memoir) to the state of the contract.

Owner can:

- Add/remove addresses to a whitelist to control who can add data to the state.

- Clean whitelist (empty)

- Add data to the state

- Remove ANY data from the state

- Clean all memoirs from state, reset state.

- Be the ONLY address allowed to add more data.

- Open up the submition of data to any address.

- Change the name of the contract at any time.

- Give owner role to another address.

- Change the max number of memoirs that can be added to state

Users can:

- Add data to the state

- Remove from the state ONLY the data sent by user

### v2: Anthology array - Anthology tree

This contract handles the state of the Anthology Tree

### v3:

How v3 can look like?

## Repository cloning

In order to use gitopia protocol, you need to install git remote helper first [Learn more](https://docs.gitopia.com/git-remote-gitopia/index.html)

Neither `https://` nor `ssh://` is used, so `gitopia://` needs to be installed.

```
git clone gitopia://Anthology/anthology-sc
```
