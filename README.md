# Muffin wallet

## Database structure

```plantuml
@startuml E/R

entity muffin_wallet {
    * id: uuid
    --
    * balance: bigdecimal
    * owner_name: varchar(40)
    * created_at: datetime
    * updated_at: datetime
}

entity muffin_transaction {
    * id: uuid
    --
    * amount: bigdecimal
    * from_muffin_wallet_id: uuid <<FK>>
    * to_muffin_wallet_id: uuid <<FK>>
    * created_at: datetime
}

muffin_transaction }|..|| muffin_wallet
@enduml
```

## Sequence Diagram

### Пример. Создание кошелька

```plantuml
@startuml
autonumber
actor User as user
participant "Muffin Wallet" as wallet #lightgreen
participant "Database" as db #lightblue

==Create muffin wallet==
user -> wallet: Request to create muffin wallet
activate wallet
wallet -> db: create record in database
activate db
wallet <-- db: created record
deactivate db
user <-- wallet: Created wallet
deactivate wallet

==Get muffin wallets==
user -> wallet: Request for showing existed wallet
activate wallet
wallet -> db: Find wallets by filter (ownerName if exists in request)
activate db
wallet <-- db: Founded wallets
deactivate db
user <-- wallet: List of wallets
deactivate wallet

==Get muffin wallet by id==
user -> wallet: Request with muffin wallet id
activate wallet
wallet -> db: Find by id
activate db
alt wallet exists
    wallet <-- db: Founded wallet
    user <-- wallet: Founded wallet
else wallet not exists
    wallet <-- db: not found
    deactivate db
    user <-- wallet: 404 not found
    deactivate wallet
end

==Transfer muffin from one wallet to another==
user -> wallet: Request with transfer from one wallet to another
activate wallet
wallet -> db: Find and lock two wallets
activate db
wallet <-- db: Locked wallets
alt locked only one wallet
    wallet -> db: Rollback
    user <-- wallet: 400 Bad request
end

wallet -> wallet: Check that muffins exists

alt not enough muffins
    wallet -> db: Rollback
    user <-- wallet: 400 Bad request
end

wallet -> db: Decrease muffin from sender wallet
wallet <-- db: Muffin was decreased 

wallet -> db: Increase muffin to sender wallet
wallet <-- db: Muffin was increased 
wallet -> wallet: Create muffin transaction
wallet -> db: Save created transaction
wallet <-- db: Saved muffin transaction
deactivate db
wallet -> user: Response with muffin transaction
deactivate wallet
@enduml

```