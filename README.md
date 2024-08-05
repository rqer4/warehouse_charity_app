# Resume 
This is mobile app for warehouse management built specifically for charity organizations.

# Features
#### Warehouse management:
- Barcode scan
- Creating new items
- Search in database of created items by scanned barcode
- Editing created items
- Deleting of items

#### Track of needs:
- Creating new needs of organization
- Adding items from storage to new need
- Setting deadline, goal and starting point for each item
- Track of pogress and time left for each item and need
#### Authorization/Registration

# Technologies
App is built on Flutter framework.

Firebase Realtime database used to store item data \(such as name, cathegory, quantity, etc)

Firebase Storage used to store images of items

# Concepts
Main goal of app - make it user-friendly as much as possible. 

Focus is on minimization of clicks user need to make in any use case to make what he wants.
# Demonstration

## Warehouse management

### Create items
Main screen.

![photo_2_2024-08-05_11-04-22](https://github.com/user-attachments/assets/7c1ca3a6-cb02-40e2-9403-44d5df7f3116)

By pressing Floating button user can choose action.

![photo_3_2024-08-05_11-04-22](https://github.com/user-attachments/assets/dd6d1240-6ba1-4f26-8d28-6b77af3e901e)

User can create new item or scan code to find out if one exists.

![photo_1_2024-08-05_11-04-22](https://github.com/user-attachments/assets/d5619db7-ba2a-4b57-a4b1-57c800cb3b45)

To create new item user must provide required info about item \(name, cathegory, quantity, measure volume, measure value and picture). Barcode isn't required 

<img src='https://github.com/user-attachments/assets/9b29b005-c1a8-4f16-8ebe-88c20ae4538d' height="400"/>.

After user fills all required fields, system allows to save new item. It displays first on the list page.

## Search by code

User presses button to search item

<img src='https://github.com/user-attachments/assets/b95eeb5d-8df0-48e4-8d72-5ced5e2cc939' height='400'/>

After code scanned if it exists in database, item displays on the screen.

<img src='https://github.com/user-attachments/assets/33481a21-dad4-44a3-9722-8eecb6c11abc' height='400'/>

User can drag left found item to delete it from databese, and drag right to edit it instantly.

<img src='https://github.com/user-attachments/assets/ebcb19de-22d2-45af-8642-95518d27d70e' height='400' /> $~~~~~~~~~~~~$ <img src='https://github.com/user-attachments/assets/3d032409-d4f6-4ed0-bbf9-a19083fed011' height='400'/>

If scanned code isn't exist in database, user will see screen below.

<img src='https://github.com/user-attachments/assets/08f2b939-6396-44e5-baf8-6df63d180e75' height='400'/>

User can instantly create new item and scanned code will be already added.
Or user can scan code again, as showed on image.

## Track of needs

Main needs screen if there are no needs

<img src='https://github.com/user-attachments/assets/86b6901d-f8c9-4403-b5b8-203e759c3a4a' height='400'/>

### Create need
By clicking "Plus" Floating button in bottom right corner, user can create new need.

<img src='https://github.com/user-attachments/assets/b535cbd0-0036-412a-9863-624b29639f1d' height='400'/>

On this screen, by clicking button in bottom right corner, user can add items for need, using barcode scanner.

<img src='https://github.com/user-attachments/assets/01fe1a7a-bef0-4bb0-8c3a-0511d51f64f7' height='400'/>

- If item was found, user can add it to need, scan code again or go back to previous screen.
- If there's no item with scanned code, user can create it instantly.
- If there are more than 1 items found, user can drag right cards he don't want to add, to remove them from screen

<img src='https://github.com/user-attachments/assets/e87723bc-7219-45e0-bb1b-8540856e9cb8' height='400'/>

After adding item to need, user can set goal and start point for that item.
By default, start point is quantity of items in storage, end goal - 1 more.
By clicking "Add need", user can save it.

<img src='https://github.com/user-attachments/assets/2151bb97-44b0-4659-8f54-9aaea2ddffba' height='400'/>

Need created. Now user can add quantity to each item and in real time see progress.




















