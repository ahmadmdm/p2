import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class OrdersGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  handleConnection(client: Socket) {
    console.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    console.log(`Client disconnected: ${client.id}`);
  }

  @SubscribeMessage('joinKitchen')
  handleJoinKitchen(client: Socket) {
    client.join('kitchen');
    console.log(`Client ${client.id} joined kitchen room`);
    return { event: 'joinedKitchen', data: true };
  }

  @SubscribeMessage('joinOrder')
  handleJoinOrder(client: Socket, orderId: string) {
    client.join(`order_${orderId}`);
    console.log(`Client ${client.id} joined order room: order_${orderId}`);
    return { event: 'joinedOrder', data: orderId };
  }

  notifyNewOrder(order: any) {
    this.server.to('kitchen').emit('newOrder', order);
  }

  notifyOrderUpdate(order: any) {
    this.server.to('kitchen').emit('orderUpdated', order);
    this.server.to(`order_${order.id}`).emit('orderStatusUpdated', order);
  }

  notifyBillRequested(table: any) {
    this.server.emit('billRequested', { 
      tableId: table.id, 
      tableNumber: table.tableNumber,
      timestamp: new Date(),
    });
  }

  notifyTableUpdate(table: any) {
    this.server.emit('tableUpdated', table);
  }
}
